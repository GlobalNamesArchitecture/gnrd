# Gathers parameters and input from users, calls name finding utitilites and
# saves their output.
class NameFinder < ActiveRecord::Base
  @queue = :NameFinder
  serialize :params, HashSerializer
  serialize :output, HashSerializer
  serialize :result, HashSerializer
  serialize :errs,   HashSerializer

  attr_accessor :text
  attr_accessor :names
  attr_accessor :timeline
  attr_accessor :resolved

  validates_with NameFinderValidator

  STATE = { 0 => :idle, 10 => :working, 20 => :finished }.freeze

  def self.token
    loop do
      t = rand(1e18..9e18).to_i.to_s(32)[0..9]
      return t unless find_by_token(t)
    end
  end

  def self.enqueue(resource)
    Resque.enqueue(NameFinder, resource.id)
  end

  def self.perform(name_finder_id)
    nf = NameFinder.find(name_finder_id)
    nf.find_names
  end

  def find_names
    self.timeline = { start: Time.now.to_f }
    prepare_text
    prepare_names
    prepare_result
  rescue Gnrd::Error => e
    add_error(e)
  ensure
    self.state = :finished
    save!
  end

  def state
    STATE[current_state]
  end

  def state=(new_state)
    res = STATE.find { |_, v| v == new_state }
    raise(IndexError, "Unknown state #{new_state}") unless res
    self.current_state = res[0]
  end

  def params_update(new_params)
    params.merge! Params.new(new_params).update
    save!
  end

  before_validation do
    unless token # needs to happen only once on creation, not on updates
      self.token = NameFinder.token
      self.params = Params.new(params).normalize if params[:source].nil?
      self.output = OutputBuilder.init(self)
    end
  end

  private

  def add_error(e)
    status_code = e.is_a?(Gnrd::UrlNotFoundError) ? 404 : 200
    errs << { status: status_code,
              message: e.message,
              parameters: Params.output(params) }
    self.state = :finished
    save!
  end

  def prepare_text
    self.text = ResultBuilder.init_text(self)
    text.text_norm
    timeline[:text_extraction] = Time.now.to_f
  end

  def prepare_names
    opts = find_names_opts
    self.names = Gnrd::NameFinderEngine.new(text.dossier, opts).find.combine
    timeline[:name_finding] = Time.now.to_f
  end

  def prepare_result
    self.result = ResultBuilder.init_result(self)
    resolve_names
    timeline[:stop] = Time.now.to_f
    result[:timeline] = timeline
    output.merge! OutputBuilder.add_result(self)
  end

  def resolve?
    result[:names].any? &&
      (params[:all_data_sources] || params[:data_source_ids].any?)
  end

  def resolve_names
    if resolve?
      result.merge!(Gnrd::Resolver.new(result[:names], params).resolve)
    end
  end

  def find_names_opts
    opts = {}
    opts[:netineti] = false if params[:engine] == 1
    opts[:taxonfinder] = false if params[:engine] == 2
    adjust_opts_for_lang(opts) if params[:detect_language]
    opts
  end

  def adjust_opts_for_lang(opts)
    opts.merge!(netineti: false) if text.english? == false
  end
end
