#!/usr/bin/env ruby
require 'sinatra'
require 'sinatra/base'
require "sinatra/reloader" if development?
require 'rack-flash'
require File.join(File.dirname(__FILE__), 'environment')

enable :sessions
use Rack::Flash

set :haml, :format => :html5

def find(params)
  @output = GNRD::NameFinder.new(params).find 
  case params[:format]
  when 'json'
    content_type 'application/json', :charset => 'utf-8'
    json_data = JSON.dump(@output)
    if params[:callback]
      # content_type 'application/javascript'
      json_data = "%s(%s)" % [params[:callback], json_data]
    end
    json_data
  when 'xml'
    content_type 'text/xml', :charset => 'utf-8'
    builder :namefinder
  else
    @title = "Discovered Names"
    @page = "home"
    @content_splash = "<h2>Discovered Names</h2>"
    flash[:error] = "The name engines failed. Administrators have been notified." if @output[:status] == "FAILED" 
    haml :name_finder
  end
end

get '/api' do
  @page = "api"
  @title = "API"
  @content_splash = "<h2>Application Programming Interface</h2>"
  haml :api
end

get '/feedback' do
  @page = 'feedback'
  @title = 'Feedback'
  @content_splash = "<h2>Feedback</h2>"
  haml :feedback
end

get '/main.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss :main
end

get "/" do
  @page = 'home'
  @content_splash = '<p class="tagline">Global Names recognition and discovery tools and services</p>'
  haml :home
end

get "/name_finder.?:format?" do
  find(params)
end

post "/name_finder.?:format?" do
  find(params)
end
