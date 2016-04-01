require "./application.rb"

set :run, false
set :environment, ENV["RACK_ENV"] ? ENV["RACK_ENV"] : :development

FileUtils.mkdir_p "log" unless File.exist?("log")

run Rack::URLMap.new("/" => Sinatra::Application,
                     "/redis" => Resque::Server)
