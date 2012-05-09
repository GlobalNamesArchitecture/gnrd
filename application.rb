#!/usr/bin/env ruby

require 'sinatra'
require File.join(File.dirname(__FILE__), 'environment')

get "/" do
 'hi'
end
