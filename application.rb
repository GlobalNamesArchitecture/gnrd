#!/usr/bin/env ruby
require 'rack/timeout'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require 'builder'

class GNRD < Sinatra::Base

  require File.join(File.dirname(__FILE__), 'environment')

  register Sinatra::Flash
  helpers Sinatra::RedirectWithFlash

  enable :sessions

  use Rack::Timeout
  Rack::Timeout.timeout = 9_000_000

  set :haml, :format => :html5
  set :protection, :except => :json_csrf

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html

    def base_url
      burl = "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
      @base_url ||= burl
    end
  end

  after do
    Cleaner.run
    ActiveRecord::Base.clear_active_connections!
  end

  def find(params)
    input_url = params[:url] || (params[:find] && params[:find][:url]) || nil
    file = params[:file] || (params[:find] && params[:find][:file]) || nil
    text = params[:text] || (params[:find] && params[:find][:text]) || nil
    unique = params[:unique] || false
    verbatim = params[:verbatim] || true
    detect_language = params[:detect_language] ||
      (params[:find] && params[:find][:detect_language]) || true
    format = params[:format] || "html"
    engine = params[:engine] || 0
    all_data_sources = params[:all_data_sources] || nil
    data_source_ids = nil
    preferred_data_sources = params[:preferred_data_sources] || nil
    best_match_only = params[:best_match_only] || false
    return_content = params[:return_content] || false
    if params[:data_source_ids]
      if params[:data_source_ids].is_a?(Hash)
        data_source_ids = params[:data_source_ids].keys.map { |i| i.to_i }
      else
        data_source_ids = params[:data_source_ids].split("|").map { |i| i.to_i }
      end
    end

    file_name = nil
    file_path = nil
    sha = nil

    if input_url.blank? && file.blank? && text.blank?
      error_presentation(format, 400)
    else
      if file
        file_name = file[:filename]
        file_path = File.join([Dir.mktmpdir] +
                              [file_name.gsub( /[^a-zA-Z0-9_\.]/, '_')])
        FileUtils.mv(file[:tempfile].path, file_path)
        sha = Digest::SHA1.file(file_path).hexdigest
      end
      all_params = {
        token_url: base_url,
        engine: engine,
        input_url: input_url,
        format: format,
        document_sha: sha,
        unique: unique,
        verbatim: verbatim,
        detect_language: detect_language,
        input: text,
        file_path: file_path,
        file_name: file_name,
        all_data_sources: all_data_sources,
        data_source_ids: data_source_ids,
        preferred_data_sources: preferred_data_sources,
        best_match_only: best_match_only,
        return_content: return_content,
      }
      nf = NameFinder.create(all_params)
      workers_running? ? Resque.enqueue(NameFinder, nf.id) : nf.name_find
      name_finder_presentation(nf, format, true)
    end
  end

  def workers_running?
    !Resque.redis.smembers('workers').select {|w| w.index("name_finder")}.empty?
  end

  def help
    Helper.instance
  end

  def redirect_with_delay(url)
    @redirect_url, @redirect_delay = url, SiteConfig.redirect_timer
  end

  def flash_messages
    flash.sweep
    queue_size = workers_running? ? Resque.size(:name_finder) : nil

    case @output[:status]
      when 303
        @output[:queue_size] = queue_size
        if queue_size > 0
          flash.now[:notice] = 'Your submission is queued for processing. ' +
            "There #{queue_size == 1 ? 'is' : 'are'} " +
            "#{help.pluralize(queue_size, "job")} in the queue."
        else
          flash.now[:notice] = "Names are being found in your submission."
        end
        flash.now[:notice] += ' This page will refresh every ' +
          "#{SiteConfig.redirect_timer} seconds."
      when 404
        flash.now[:warning] = "That URL was inaccessible."
      when 500
        flash.now[:error] = 'The name engines failed. ' +
          'Administrators have been notified.'
    end
  end

  def name_finder_presentation(name_finder_instance, format,
                               do_redirect = false)
    @title = "Discovered Names"
    @page = "home"
    @header = "Discovered Names"
    @output = name_finder_instance.output
    @redirect_url = nil

    case format
      when 'json'
        redirect name_finder_instance.token_url, 303 if do_redirect
        json_data = JSON.dump(@output)
        if params[:callback]
          json_data = "%s(%s)" % [params[:callback], json_data]
        end
        content_type 'application/json', :charset => 'utf-8'
        json_data
      when 'xml'
        redirect name_finder_instance.token_url, 303 if do_redirect
        content_type 'text/xml', :charset => 'utf-8'
        builder :namefinder
      else
        flash_messages
        redirect name_finder_instance.token_url if do_redirect
        if @output[:status] == 303
          redirect_with_delay(name_finder_instance.token_url)
        end
        @output[:token] = name_finder_instance.token
        @meta_norobots = true
        haml :name_finder
      end
  end

  def error_presentation(format, output_status = 404)
    @output = { :status => output_status, :message => nil }

    case output_status
      when 400
        @output[:message] = 'Bad Request. Parameters missing.'
      when 404
        @output[:message] = 'Not Found. That result no longer exists.'
      when 500
        @output[:message] = 'The name engines failed. ' +
          'Administrators have been notified.'
    end

    case format
      when 'json'
        status output_status
        content_type 'application/json', charset: 'utf-8'
        JSON.dump(@output)
      when 'xml'
        status output_status
        content_type 'text/xml', charset: 'utf-8'
        builder :namefinder
      else
        flash.sweep
        flash.now[:error] = @output[:message]
        redirect "/" if output_status == 400
        haml :fail
    end
  end

  get "/" do
    @page = "home"
    @tagline = "Global Names recognition and discovery tools and services"
    haml :home
  end

  get '/api' do
    @page = "api"
    @title = "API"
    @header = "Application Programming Interface"
    base_url
    haml :api
  end

  get '/feedback' do
    @page = "feedback"
    @title = "Feedback"
    @header = "Feedback"
    haml :feedback
  end

  get '/history' do
    @page = "history"
    @title = "History"
    @header = "History"
    @records = NameFinder.find(:all, select: [
                               "token", "input_url",
                               "file_name", "created_at"],
                               conditions: "input_url <> '' OR file_name <> ''",
                               order: 'created_at DESC')
    @meta_norobots = true
    haml :history
  end

  get '/main.css' do
    content_type 'text/css', charset: 'utf-8'
    scss :main
  end

  get "/name_finder.?:format?" do
    if params[:token]
      begin
        nf = NameFinder.find_by_token(params[:token])
        name_finder_presentation(nf, params[:format])
      rescue
        error_presentation(params[:format])
      end
    else
      find(params)
    end
  end

  post "/name_finder.?:format?" do
    find(params)
  end

  not_found do
    if @output.nil?
      status 404
      flash.sweep
      haml :'404'
    end
  end

  run! if app_file == $0

end
