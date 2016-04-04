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
require_relative "models/name_finder_worker"
require_relative "models/name_finder"
require_relative "models/today"

# Namespace module for Global Names Recognition and Discovery
module Gnrd
  ENVIRONMENTS = %i(development test production).freeze

  class << self
    def init
      dir
      db_connections
    end

    # directory to keep temporary files
    def dir
      @dir ||= lambda do
        temp_dir = "#{Gnrd.conf.tmp_dir}/gnrd"
        FileUtils.mkdir(temp_dir) unless Dir.exist?(temp_dir)
        temp_dir
      end[]
    end

    def env
      @env ||= ENV["RACK_ENV"] ? ENV["RACK_ENV"].to_sym : :development
    end

    def env=(env)
      if ENVIRONMENTS.include?(env)
        @env = env
      else
        raise TypeError, "Wrong environment: '#{env}'"
      end
    end

    def conf
      @conf ||= lambda do
        conf = conf_default.each_with_object({}) do |h, obj|
          obj[h[0]] = conf_file[h[0]] ? conf_file[h[0]] : h[1]
        end
        OpenStruct.new(conf)
      end[]
    end

    def db_conf
      ENVIRONMENTS.each_with_object({}) do |e, obj|
        obj[e.to_s] = { "adapter" => "postgresql", "encoding" => "unicode",
                        "database" => "gnrd_#{e}", "pool" => 5,
                        "username" => "postgres", "password" => nil,
                        "host" => "pg" }
      end
    end

    def db_connections
      @db ||= connect
      @redis ||= redis_connect
    end

    def disconnect
      ActiveRecord::Base.connection.disconnect!
    rescue ActiveRecord::ConnectionNotEstablished
      puts "Setting new connection"
    end

    private

    def connect
      ActiveRecord::Base.logger = Logger.new(__dir__ + "/log/postgres.log")
      ActiveRecord::Base.logger.level = Logger::DEBUG
      ActiveRecord::Base.configurations = Gnrd.conf.database
      ActiveRecord::Base.establish_connection(env)
    end

    def redis_connect
      Resque.redis = Gnrd.conf.redis_host
    end

    def conf_default
      { "redis_host" => "redis",
        "database" => db_conf, "session_secret" => "!!change!!me!!",
        "tmp_dir" => "/tmp", "neti_neti_host" => "nn",
        "neti_neti_port" => 6384, "taxon_finder_host" => "tf",
        "taxon_finder_port" => 1234, "disqus_shortname" => "globalnames-rd",
        "resolver_url" => "http://res.globalnames.org/name_resolvers.json" }
    end

    def conf_file
      @conf_file ||= lambda do
        path = File.join(__dir__, "config", "config.json")
        File.exist?(path) ? JSON.parse(File.read(path)) : {}
      end[]
    end
  end
end

Gnrd.init
