module Gnrd
  def self.env
    @env ||= ENV["RACK_ENV"] ? ENV["RACK_ENV"].to_sym : :development
  end

  def self.env=(env)
    if [:development, :test, :production].include(env)
      @env = env
    else
      fail TypeError, "Wrong environment: '#{env}'"
    end
  end

  def self.conf
    @conf ||= new_conf
  end

  private

  def self.new_conf
    raw_conf = File.read(File.join(__dir__, "config", "config.yml"))
    conf = YAML.load(raw_conf)
    OpenStruct.new(
      session_secret:   conf["session_secret"],
     )
  end
end

