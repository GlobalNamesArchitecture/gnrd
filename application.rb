#!/usr/bin/env ruby
require 'sinatra'
require 'rack-flash'
require File.join(File.dirname(__FILE__), 'environment')

enable :sessions
use Rack::Flash

set :haml, :format => :html5

def find(params)
  @output = GNRD::NameFinder.new(params).find 
  puts @output 
end


get '/main.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss :main
end

get "/" do
  @page = 'home'
  haml :home
end

get "/find.?:format?" do
  find(params)
end

post "/find.?:format?" do
  find(params)
end
