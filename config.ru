require "./application.rb"

set :run, false
set :environment, ENV["RACK_ENV"] ? ENV["RACK_ENV"] : :development

FileUtils.mkdir_p "log" unless File.exist?("log")
log = File.new("log/sinatra.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)

run Sinatra::Application
