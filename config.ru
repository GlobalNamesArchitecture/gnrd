require "./application.rb"

set :run, false
set :environment, ENV["RACK_ENV"] ? ENV["RACK_ENV"] : :development

run Sinatra::Application
