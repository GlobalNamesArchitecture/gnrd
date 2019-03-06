# frozen_string_literal: true

require "active_record"
require "docsplit"
require "filemagic"
require "fileutils"
require "json"
require "logger"
require "ostruct"
require "rchardet"
require "resque"
require "resque/server"
require "rest_client"
require "sanitize"
require "gnfinder"

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
  ENVIRONMENTS = %i[development test production].freeze

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
      unless ENVIRONMENTS.include?(env)
        raise TypeError.new("Wrong environment: '#{env}'")
      end

      @env = env
    end

    def conf
      @conf ||= lambda do
        conf = conf_default.each_with_object({}) do |h, obj|
          obj[h[0]] = conf_file[h[0]] || h[1]
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

    # rubocop:disable Naming/MemoizedInstanceVariableName
    def db_connections
      @db ||= connect
      @redis ||= redis_connect
    end
    # rubocop:enable Naming/MemoizedInstanceVariableName

    def disconnect
      ActiveRecord::Base.connection.disconnect!
    rescue ActiveRecord::ConnectionNotEstablished
      puts "Setting new connection"
    end

    private

    def connect
      ActiveRecord::Base.logger = Logger.new(__dir__ + "/log/postgres.log")
      ActiveRecord::Base.logger.level = Logger::INFO
      ActiveRecord::Base.configurations = Gnrd.conf.database
      ActiveRecord::Base.establish_connection(env)
    end

    def redis_connect
      Resque.redis = Gnrd.conf.redis_host
    end

    def conf_default
      {
        "redis_host" => "redis", "tmp_dir" => "/tmp",
        "database" => db_conf, "session_secret" => "!!change!!me!!",
        "gnfinder_host" => "gnf", "gnfinder_port" => 8778,
        "disqus_shortname" => "globalnames-rd"
      }
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
