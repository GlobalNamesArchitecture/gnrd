# Gathers parameters and input from users, calls name finding utitilites and
# saves their output.
class NameFinder < ActiveRecord::Base
  @queue = :NameFinder
  %i(params output result errs).each { |f| serialize f, HashSerializer }

  attr_accessor :text, :names, :timeline, :resolved

  validates_with NameFinderValidator

  STATE = { 0 => :idle, 10 => :working, 20 => :finished }.freeze

  def self.token
    loop do
      t = rand(1e18..9e18).to_i.to_s(32)[0..9]
      return t unless find_by_token(t)
    end
  end

  def self.enqueue(nf)
    Resque.enqueue(NameFinder, nf.id)
    nf.state = :working
    nf.save!
  end

  def self.perform(name_finder_id)
    nf = NameFinder.find(name_finder_id)
    NameFinderWorker.find_names(nf)
  end

  def state
    STATE[current_state]
  end

  def state=(new_state)
    res = STATE.find { |_, v| v == new_state }
    raise(IndexError.new("Unknown state #{new_state}")) unless res
    self.current_state = res[0]
  end

  def params_update(new_params)
    params.merge!(Params.new(new_params).update)
    save!
  end

  def add_error(e)
    status_code = e.respond_to?(:status_code) ? e.status_code.to_i : 200
    errs << { status: status_code, message: e.message,
              parameters: Params.output(params) }
  end

  before_validation do
    unless token # needs to happen only once on creation, not on updates
      self.token = NameFinder.token
      self.params = Params.new(params).normalize if params[:source].nil?
      self.output = OutputBuilder.init(self)
    end
  end

  after_validation do
    create_temp_file unless params[:file_path]
  end

  before_destroy { File.rm(params[:file_path]) if filepath? }

  private

  def create_temp_file
    return move_tempfile if tempfile?
    make_url_file if url?
  end

  def make_url_file
    url = normalize_url
    wd = Gnrd::WebDownloader.new
    params[:file_path] = wd.download(url, token)
  rescue Gnrd::Error => e
    add_error(e)
    params[:file_path] = path(".txt")
  ensure
    FileUtils.touch(params[:file_path])
  end

  def normalize_url
    url = params[:source][:url]
    url =~ %r{^http[s]?://} ? url : "http://" + url
  end

  def move_tempfile
    tempfile = params[:source][:file].delete(:tempfile)
    ext = File.extname(tempfile)
    params[:file_path] = path(ext)
    FileUtils.mv(tempfile, params[:file_path])
    save!
  end

  def path(ext = ".txt")
    "#{Gnrd.dir}/#{token}#{ext}"
  end

  def filepath?
    defined?(params[:file_path]) && params[:file_path]
  end

  def tempfile?
    defined?(params[:source][:file][:tempfile]) &&
      params[:source][:file][:tempfile]
  end

  def url?
    params[:source][:url]
  end
end
