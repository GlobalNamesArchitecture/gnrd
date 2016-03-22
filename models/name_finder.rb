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
    self.text = ResultBuilder.init_text(self)
    self.timeline = { start: Time.now.to_f }
    self.text.text_norm
    self.timeline[:text_extraction] = Time.now.to_f
    opts = find_names_opts
    self.names = Gnrd::NameFinderEngine.new(text.dossier, opts).find.combine
    self.timeline[:name_finding] = Time.now.to_f
    self.result = ResultBuilder.init_result(self)
    if resolve?
      self.result.merge!(ResultBuilder.add_resolution(resolve)) if resolve?
    end
    self.timeline[:stop] = Time.now.to_f
    self.result.merge!(timeline: timeline)
    self.status_code = 200
    self.output.merge! OutputBuilder.add_result(self)
    self.state = :finished
    self.save!
  end

  def state
    STATE[current_state]
  end

  def state=(new_state)
    res = STATE.find { |k, v| v == new_state }
    if res && res[0] != state
      self.current_state = res[0]
    else
      raise IndexError, "Unknown state #{new_state}"
    end
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
