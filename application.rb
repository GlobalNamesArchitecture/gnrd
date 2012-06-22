#!/usr/bin/env ruby
require 'rack/timeout'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/flash'
require 'builder'
require File.join(File.dirname(__FILE__), 'environment')

enable :sessions

use Rack::Timeout
Rack::Timeout.timeout = 9_000_000

set :haml, :format => :html5

def find(params)
  input_url = params[:url] || (params[:find] && params[:find][:url]) || nil
  file = params[:file] || (params[:find] && params[:find][:file]) || nil
  text = params[:text] || (params[:find] && params[:find][:text]) || nil

  unique = params[:unique] || false
  verbatim = params[:verbatim] || true
  format = params[:format] || "html"
  engine = params[:engine] || 0
  file_name = nil
  file_path = nil
  sha = nil
  
  if input_url.blank? && file.blank? && text.blank?
    error_presentation(format, 400)
  else
    if file
      file_name = file[:filename]
      file_path = File.join([Dir.mktmpdir] + [file_name])
      FileUtils.mv(file[:tempfile].path, file_path)
      sha = Digest::SHA1.file(file_path).hexdigest
    end

    nf = NameFinder.create(:engine => engine, :input_url => input_url, :format => format, :document_sha => sha, :unique => unique, :verbatim => verbatim, :input => text, :file_path => file_path, :file_name => file_name)

    if ['xml', 'json'].include?(format) && workers_running? && text_large?(text)
      Resque.enqueue(NameFinder, nf.id)
    else
      nf.name_find
    end
    name_finder_presentation(nf, format, true)
  end
end

def text_large?(text)
  !text || text.size > 5000
end

def workers_running?
  !Resque.redis.smembers('workers').select {|w| w.index("name_finder")}.empty?
end

def name_finder_presentation(name_finder_instance, format, do_redirect = false) 
  @title = "Discovered Names"
  @page = "home"
  @header = "Discovered Names"
  @output = name_finder_instance.output
  flash.sweep
  flash.now[:warning] = "That URL was inaccessible." if @output[:status] == 404
  if @output[:status] == 500
    status 500
    @output[:message] = "The name engines failed. Administrators have been notified."
    flash.now[:error] = @output[:message]
  end
  case format
  when 'json'
    content_type 'application/json', :charset => 'utf-8'
    json_data = JSON.dump(@output)
    if params[:callback]
      json_data = "%s(%s)" % [params[:callback], json_data]
    end
    json_data
  when 'xml'
    content_type 'text/xml', :charset => 'utf-8'
    builder :namefinder
  else
    if do_redirect
      redirect name_finder_instance.url
    else
      haml :name_finder
    end
  end
end

def error_presentation(format, output_status = 404)
  @output = { :status => output_status, :message => nil }

  case output_status
  when 400
     @output[:message] = "Bad Request. Parameters missing."
  when 404
    @output[:message] = "Not Found. That result no longer exists."
  when 500
    @output[:message] = "Internal Server Error. Name-finding engines are offline."
  end

  case format
  when 'json'
    status output_status
    content_type 'application/json', :charset => 'utf-8'
    JSON.dump(@output)
  when 'xml'
    status output_status
    content_type 'text/xml', :charset => 'utf-8'
    builder :namefinder
  else
    flash.sweep
    flash.now[:error] = @output[:message]
    if output_status == 400
      redirect "/"
    else
      haml :fail
    end
  end
end

get '/api' do
  @page = "api"
  @title = "API"
  @header = "Application Programming Interface"
  haml :api
end

get '/feedback' do
  @page = "feedback"
  @title = "Feedback"
  @header = "Feedback"
  haml :feedback
end

get '/main.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss :main
end

get "/" do
  @page = "home"
  @tagline = "Global Names recognition and discovery tools and services"
  haml :home
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
