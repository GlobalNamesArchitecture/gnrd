#!/usr/bin/env ruby
require 'sinatra'
require 'sinatra/base'
# require "sinatra/reloader" if development?
require 'sinatra/flash'
require 'builder'
require File.join(File.dirname(__FILE__), 'environment')

enable :sessions

set :haml, :format => :html5

def find(params)
  input_url = params[:url] || (params[:find] && params[:find][:url]) || nil
  input = params[:input] || (params[:find] && params[:find][:input]) || nil
  unique = params[:unique] || false
  format = params[:format] || "html"
  engine = params[:engine] || "Both"
  file = params[:file] || (params[:find] && params[:find][:file]) || nil
  file_name = file ? file[:filename] : nil
  upload_path = file ? file[:tempfile].path : nil
  file_path = nil
  if upload_path && file_name
    file_path = File.join(File.split(upload_path)[0..-2] + [file_name])
    FileUtils.mv(upload_path, file_path)
  end
  sha = file ? Digest::SHA1.file(file_path).hexdigest : nil
  

  token = "_"
  while token.match(/[_-]/) 
    token = Base64.urlsafe_encode64(UUID.create_v4.raw_bytes)[0..-3]
  end
  
  nf = NameFinder.create(:engine => engine, :input_url => input_url, :format => format, :token => token, :document_sha => sha, :unique => unique, :input => input, :file_path => file_path, :file_name => file_name)
  if ['xml', 'json'].include?(format) && workers_running? && input_large?(input)
    Resque.enqueue(NameFinder, nf.id)
  else
    nf.name_find
  end
  name_finder_presentation(nf, format, true)
end

def input_large?(input)
  !input || input.size > 5000 
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
  flash.now[:error] = "The name engines failed. Administrators have been notified." if @output[:status] == "FAILED"
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
      redirect  name_finder_instance.url
    else
      haml :name_finder
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
    nf = NameFinder.find_by_token(params[:token])
    name_finder_presentation(nf, params[:format])
  else
    find(params)
  end
end

post "/name_finder.?:format?" do
  find(params)
end
