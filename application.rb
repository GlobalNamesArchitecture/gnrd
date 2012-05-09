#!/usr/bin/env ruby
require 'sinatra'
require File.join(File.dirname(__FILE__), 'environment')

set :haml, :format => :html5

get '/main.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss :main
end

get "/" do
  haml :home
end
