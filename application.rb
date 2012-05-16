#!/usr/bin/env ruby
require 'sinatra'
require 'sinatra/base'
require "sinatra/reloader" if development?
require 'rack-flash'
require 'builder'
require File.join(File.dirname(__FILE__), 'environment')

enable :sessions
use Rack::Flash

set :haml, :format => :html5

def find(params)
  url = params[:url] || (params[:find] && params[:find][:url]) || nil
  file_path = params[:file] || (params[:find] && params[:find][:file]) || nil
  input = params[:input] || (params[:find] && params[:find][:input]) || nil
  unique = params[:unique] || false
  format = params[:format] || "html"
  engine = params[:engine] || "Both"
  token = "_"
  while token.match(/_/) 
    token = Base64.urlsafe_encode64(UUID.create_v4.raw_bytes)[0..-3]
  end
  nf = NameFinder.create(:token => token, :url => url, :file_path => file_path, :input => input, :engine => engine, :format => format, :unique => unique)
  Resque.enqueue(NameFinder, nf.id) rescue nf.name_find
  Resque.enqueue_in(7.days, NameFinderNuke, nf.id) rescue nil
  @output = nf.output
  case params[:format]
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
    redirect  "/name_finder/#{nf.token}"
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

get "/name_finder/:token.?:format?" do
  nf = NameFinder.find_by_token(params[:token])
  @page = "home"
  @title = "Discovered Names"
  @header = "Discovered Names"
  @output = nf.output
  flash[:error] = "The name engines failed. Administrators have been notified." if @output[:status] == "FAILED"
  haml :name_finder
end

get "/name_finder.?:format?" do
  find(params)
end

post "/name_finder.?:format?" do
  find(params)
end
