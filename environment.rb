require "fileutils"
require "filemagic"
require "docsplit"
require "sanitize"
require "rchardet"
require "ostruct"
require "psych"
require "name-spotter"

# Namespace module for Global Names Recognition and Discovery
module Gnrd
  def self.env
    @env ||= ENV["RACK_ENV"] ? ENV["RACK_ENV"].to_sym : :development
  end

  def self.env=(env)
    if [:development, :test, :production].include?(env)
      @env = env
    else
      raise TypeError, "Wrong environment: '#{env}'"
    end
  end

  def self.conf
    @conf ||= new_conf
  end

  def self.new_conf
    conf_file = Psych.load_file(File.join(__dir__, "config", "config.yml"))
    conf = {
      session_secret: "!!change!!me!!", tmp_dir: "/tmp",
      neti_neti_host: "nn", neti_neti_port:  6384,
      taxon_finder_host: "tf", taxon_finder_port: 1234
    }.each_with_object({}) { |h, obj| obj[h[0]] = conf_file[h[0].to_s] || h[1] }
    OpenStruct.new(conf)
  end
end
