# Gathers parameters and input from users, calls name finding utitilites and
# saves their output.
class NameFinder < ActiveRecord::Base
  serialize :params, HashSerializer
  serialize :errs, HashSerializer
  serialize :output, HashSerializer
  serialize :result, HashSerializer

  attr_accessor :text
  attr_accessor :names
  attr_accessor :timeline

  STATE = { 0 => :idle, 10 => :working, 20 => :finished }.freeze

  def self.token
    loop do
      t = rand(1e18..9e18).to_i.to_s(32)[0..9]
      return t unless find_by_token(t)
    end
  end

  def self.enqueue(resource)
    Resque::Job.create(self, resource.id)
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

  def errors?
    self.errs = Errors.new(self).validate if errs.is_a?(Hash)
    if errs.empty?
      false
    else
      save_error
    end
  end

  before_create do
    self.token = NameFinder.token
    self.params = Params.new(params).normalize
    self.output = OutputBuilder.init(self)
  end

  private

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
    self.status_code = 200
    self.result = ResultBuilder.init_result(self)
    result.merge!(ResultBuilder.add_resolution(self)) if resolve?
    timeline[:stop] = Time.now.to_f
    result[:timeline] = timeline
    output.merge! OutputBuilder.add_result(self)
  end

  def resolve?
    false
  end

  def save_error
    self.status_code = errs.first[:status_code]
    self.output = { status: errs.first[:status_code],
                    message: errs.first[:message] }
    save!
    true
  end

  def find_names_opts
    opts = {}
    opts[:neti_neti] = false if params[:engine] == 1
    opts[:taxon_finder] = false if params[:engine] == 2
    opts
  end
end
