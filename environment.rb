require "fileutils"
require "filemagic"
require "docsplit"
require "sanitize"
require "rchardet"
require "ostruct"
require "json"
require "name-spotter"
require "logger"
require "active_record"
require "resque"
require "resque/server"

require_relative "models/hash_serializer"
require_relative "models/params"
require_relative "models/result_builder"
require_relative "models/output_builder"
require_relative "models/name_finder_validator"
require_relative "models/name_finder"

# Namespace module for Global Names Recognition and Discovery
module Gnrd
  ENVIRONMENTS = %i(development test production).freeze

  def self.env
    @env ||= ENV["RACK_ENV"] ? ENV["RACK_ENV"].to_sym : :development
  end

  def self.env=(env)
    if ENVIRONMENTS.include?(env)
      @env = env
    else
      raise TypeError, "Wrong environment: '#{env}'"
    end
  end

  def self.conf
    @conf ||= new_conf
  end

  def self.db_connections
    @db ||= connect
    @redis ||= redis_connect
  end

  def self.disconnect
    ActiveRecord::Base.connection.disconnect!
  rescue ActiveRecord::ConnectionNotEstablished
    puts "Setting new connection"
  end

  def self.connect
    ActiveRecord::Base.logger = Logger.new(__dir__ + "/log/postgres.log")
    ActiveRecord::Base.logger.level = Logger::DEBUG
    ActiveRecord::Base.configurations = Gnrd.conf.database
    ActiveRecord::Base.establish_connection(env)
  end

  def self.redis_connect
    Resque.redis = Gnrd.conf.redis_host
  end

  def self.new_conf
    conf = conf_default.each_with_object({}) do |h, obj|
      obj[h[0]] = conf_file[h[0]] ? conf_file[h[0]] : h[1]
    end
    OpenStruct.new(conf)
  end

  def self.conf_default
    { "redis_host" => "redis",
      "database" => db_conf, "session_secret" => "!!change!!me!!",
      "tmp_dir" => "/tmp", "neti_neti_host" => "nn",
      "neti_neti_port" => 6384, "taxon_finder_host" => "tf",
      "taxon_finder_port" => 1234, "disqus_shortname" => "globalnames-rd",
      "resolver_url" => "http://res.globalnames.org/name_resolvers.json" }
  end

  def self.conf_file
    @conf_file ||= new_conf_file
  end

  def self.new_conf_file
    path = File.join(__dir__, "config", "config.json")
    File.exist?(path) ? JSON.parse(File.read(path)) : {}
  end

  def self.db_conf
    ENVIRONMENTS.each_with_object({}) do |e, obj|
      obj[e.to_s] = { "adapter" => "postgresql", "encoding" => "unicode",
                      "database" => "gnrd_#{e}", "pool" => 5,
                      "username" => "postgres", "password" => nil,
                      "host" => "pg" }
    end
  end
end

Gnrd.db_connections
