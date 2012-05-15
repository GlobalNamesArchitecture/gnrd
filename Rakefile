require 'bundler/setup'
require 'rspec/core/rake_task'
# require 'escape'
require 'resque'
require 'resque/tasks'

task :default => :test
task :test => :spec

if !defined?(RSpec)
  puts "spec targets require RSpec"
else
  desc "Run all examples"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/**/*.rb'
    t.rspec_opts = ['-cfs']
  end
end

namespace :resque do
  task :setup => :environment do
    puts 'Setting Environment'
  end

  task :stop_workers => :setup do
    desc "Finds and quits all running workers"
    puts "Quitting resque workers"
    pids = Array.new
    Resque.workers.each do |worker|
      pids.concat(worker.worker_pids)
    end
    unless pids.empty? 
      system("kill -QUIT #{pids.join(' ')}")
      god_pid = "/var/run/god/resque-1.10.0.pid" 
      FileUtils.rm god_pid if File.exists? god_pid
    end
  end
end

# usage: rake generate:migration[name_of_migration]
namespace :generate do
  task(:migration, :migration_name) do |t, args|
    timestamp = Time.now.gmtime.to_s[0..18].gsub(/[^\d]/, '')
    migration_name = args[:migration_name]
    file_name = "%s_%s.rb" % [timestamp, migration_name]
    class_name = migration_name.split("_").map {|w| w.capitalize}.join('')
    path = File.join(File.expand_path(File.dirname(__FILE__)), 'db', 'migrate', file_name)
    f = open(path, 'w')
    content = "class #{class_name} < ActiveRecord::Migration
  def up
  end
  
  def down
  end
end
"
    f.write(content)
    puts "Generated migration %s" % path
    f.close
 end
end

namespace :db do
  require 'active_record'
  conf = YAML.load(open(File.join(File.expand_path(File.dirname(__FILE__)), 'config.yml')).read)
  desc "Migrate the database"
  task(:migrate => :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end

  namespace :drop do
    task(:all) do
      conf.each do |k, v| 
        if ['0.0.0.0', '127.0.0.1', 'localhost'].include?(v['host'].strip)
          database = v.delete('database')
          ActiveRecord::Base.establish_connection(v)
          ActiveRecord::Base.connection.execute("drop database if exists  #{database}")
        end
      end
    end
  end
  
  namespace :create do
    task(:all) do
      conf.each do |k, v| 
        if ['0.0.0.0', '127.0.0.1', 'localhost'].include?(v['host'].strip)
          database = v.delete('database')
          ActiveRecord::Base.establish_connection(v)
          ActiveRecord::Base.connection.execute("create database if not exists  #{database}")
        end
      end
    end
  end

end

task :environment do
  require_relative './environment'
end
