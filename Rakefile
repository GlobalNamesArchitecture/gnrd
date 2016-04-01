require "rake"
require "bundler/setup"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "resque"
require "resque/tasks"
require "active_record"
require "sinatra/activerecord/rake"

require_relative "lib/gnrd"

RSpec::Core::RakeTask.new(:spec) { |t| t.pattern = "spec/**/*.rb" }
RuboCop::RakeTask.new

task default: [:rubocop, :spec]

include ActiveRecord::Tasks
ActiveRecord::Base.configurations = Gnrd.conf.database

Resque.logger = Logger.new("log/resque.log")

Gnrd.db_connections

task :environment do
  require_relative "environment"
end

namespace :db do
  desc "create all the databases"
  namespace :create do
    task(:all) do
      DatabaseTasks.create_all
    end
  end

  desc "drop all the databases"
  namespace :drop do
    task(:all) do
      DatabaseTasks.drop_all
    end
  end

  desc "redo last migration"
  task redo: ["db:rollback", "db:migrate"]
end

namespace :resque do
  task setup: :environment

  task stop_workers: :setup do
    desc "Finds and quits all running workers"
    puts "Quitting resque workers"
    pids = []
    Resque.workers.each do |worker|
      pids.concat(worker.worker_pids)
    end
    unless pids.empty?
      system("kill -QUIT #{pids.join(' ')}")
      god_pid = "/var/run/god/resque.pid"
      FileUtils.rm god_pid if File.exist? god_pid
    end
  end
end

desc "open an irb session preloaded with this library"
task :console do
  sh "irb -I lib -I #{__dir__} -r application.rb"
end
