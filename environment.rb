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

  def self.db_connection
    @db ||= connect
  end

  def self.connect
    ActiveRecord::Base.logger = Logger.new(__dir__ + "/log/postgres.log")
    ActiveRecord::Base.logger.level = Logger::DEBUG
    ActiveRecord::Base.configurations = Gnrd.conf.database
    ActiveRecord::Base.establish_connection(env)
  end

  def self.db_close
    @db.close if @@db
  end

  def self.new_conf
    conf = {
      "database" => db_conf,
      "session_secret" => "!!change!!me!!", "tmp_dir" => "/tmp",
      "neti_neti_host" => "nn", "neti_neti_port" => "tf",
      "taxon_finder_port" => 1234, "disqus_shortname" => "globalnames-rd"
    }.each_with_object({}) do |h, obj|
      obj[h[0]] = conf_file[h[0]] ? conf_file[h[0]] : h[1]
    end
    OpenStruct.new(conf)
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

# Gnrd.db_connection
