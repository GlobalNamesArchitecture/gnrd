require "./application.rb"

set :run, false
set :environment, ENV["RACK_ENV"] ? ENV["RACK_ENV"] : :development

# Allows to use puts etc for logging
FileUtils.mkdir_p "log" unless File.exist?("log")
custom_log = File.new("log/sinatra_stdio.log", "a")
STDOUT.reopen(custom_log)
STDERR.reopen(custom_log)

run Rack::URLMap.new("/" => Sinatra::Application,
                     "/redis" => Resque::Server)
