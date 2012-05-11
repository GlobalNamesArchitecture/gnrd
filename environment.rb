require 'bundler/setup'
require 'sinatra'
require 'haml'
require 'sass'
require 'ostruct'
require 'yaml'
require 'active_record'
require 'logger'
require 'name-spotter'

#set environment
environment = ENV["RACK_ENV"] || ENV["RAILS_ENV"]
environment = (environment && ["production", "test", "development"].include?(environment.downcase)) ? environment.downcase.to_sym : :development
Sinatra::Base.environment = environment


#configure
root_path = File.expand_path(File.dirname(__FILE__))
conf = YAML.load(open(File.join(root_path, 'config.yml')).read)[Sinatra::Base.environment.to_s]
configure do
  SiteConfig = OpenStruct.new(
                 :title => 'Global Names Recognition and Discovery',
                 :url_base => conf.delete('url_base'),
                 :root_path => root_path,
                 :files_path => File.join(root_path, 'public', 'files'),
                 :salt => conf.delete('salt'),
                 :disqus_shortname => 'globalnames-rd',
               )

  # to see sql during tests uncomment next line
  ActiveRecord::Base.logger = Logger.new(STDOUT, :debug)
  ActiveRecord::Base.establish_connection(conf)

  # load models
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib', 'gnrd'))
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'models'))
  Dir.glob(File.join(File.dirname(__FILE__), 'lib', '**', '*.rb')) { |lib|   require File.basename(lib, '.*') }
  Dir.glob(File.join(File.dirname(__FILE__), 'models', '*.rb')) { |model| require File.basename(model, '.*') }
end
