require 'bundler/setup'
require 'sinatra'
require 'haml'
require 'sass'
require 'ostruct'
require 'yaml'
require 'active_record'
require 'logger'
require 'name-spotter'
require 'uri'
require 'tmpdir'
require 'mechanize'
require 'docsplit'
require 'resque'
require 'rack/google-analytics'
require 'digest/sha1'

#set environment
environment = ENV["RACK_ENV"] || ENV["RAILS_ENV"]
environment = (environment && ["production", "test", "development"].include?(environment.downcase)) ? environment.downcase.to_sym : :development
Sinatra::Base.environment = environment

#set encoding
Encoding.default_external = "UTF-8"

#configure
root_path = File.expand_path(File.dirname(__FILE__))
conf = YAML.load(open(File.join(root_path, 'config.yml')).read)[Sinatra::Base.environment.to_s]
configure do
  SiteConfig = OpenStruct.new(
                 :title => 'Global Names Recognition and Discovery',
                 :url_base => conf.delete('url_base'),
                 :root_path => root_path,
                 :salt => conf.delete('salt'),
                 :disqus_shortname => 'globalnames-rd',
                 :redirect_timer => 10,
               )

  # to see sql during tests uncomment next line
  ActiveRecord::Base.logger = Logger.new(STDOUT, :debug)
  ActiveRecord::Base.establish_connection(conf)
  # ActiveRecord::Base.schema_format = :sql

  # load models
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib', 'gnrd'))
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'models'))
  Dir.glob(File.join(File.dirname(__FILE__), 'lib', '**', '*.rb')) { |lib| require File.basename(lib, '.*') }
  Dir.glob(File.join(File.dirname(__FILE__), 'models', '*.rb')) { |model| require File.basename(model, '.*') }
end

#production-specific
site_specific_file =  File.join(File.dirname(__FILE__), 'config', 'production_site_specific')
require site_specific_file if File.exists?(site_specific_file + ".rb")

after do
  Cleaner.run
  ActiveRecord::Base.clear_active_connections!
end
