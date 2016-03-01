require "./application.rb"

set :run, false
set :environment, :production

FileUtils.mkdir_p "log" unless File.exist?("log")
log = File.new("log/sinatra.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)

run GNRD
