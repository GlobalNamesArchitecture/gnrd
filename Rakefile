require "rake"
require "bundler/setup"
require "rspec/core/rake_task"
# require "escape"
require "resque"
require "resque/tasks"
require "active_record"
require "sinatra/activerecord/rake"

require_relative "lib/gnrd"

task default: :spec

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/**/*.rb"
end

namespace :db do
  desc "create all the databases from config.yml"
  namespace :create do
    task(:all) do
      DatabaseTasks.create_all
    end
  end

  desc "drop all the databases from config.yml"
  namespace :drop do
    task(:all) do
      DatabaseTasks.drop_all
    end
  end

  desc "redo last migration"
  task redo: ["db:rollback", "db:migrate"]
end

namespace :resque do
  task setup: :environment do
    puts "Setting Environment"
  end

  task stop_workers: :setup do
    desc "Finds and quits all running workers"
    puts "Quitting resque workers"
    pids = []
    Resque.workers.each do |worker|
      pids.concat(worker.worker_pids)
    end
    unless pids.empty?
      system("kill -QUIT #{pids.join(' ')}")
      god_pid = "/var/run/god/resque-1.10.0.pid"
      FileUtils.rm god_pid if File.exist? god_pid
    end
  end
end

desc "open an irb session preloaded with this library"
task :console do
  sh "irb -I lib -I extra -r gnrd.rb"
end
