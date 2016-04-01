require "rack-timeout"
require "sinatra"
require "sinatra/base"
require "sinatra/flash"
require "sinatra/redirect_with_flash"
require "tilt/haml"
require "tilt/sass"
require "tilt/builder"

require_relative "lib/gnrd"
require_relative "models/hash_serializer"
require_relative "models/params"
require_relative "models/result_builder"
require_relative "models/output_builder"
require_relative "models/name_finder_validator"
require_relative "models/name_finder"

require_relative "sinatra/post_get"
require_relative "routes"
require_relative "helpers"

configure do
  register Sinatra::Flash, Sinatra::PostGet
  helpers Sinatra::RedirectWithFlash

  enable :sessions

  use Rack::Timeout
  Rack::Timeout.timeout = 9_000_000

  set :haml, format: :html5
  set :protection, except: :json_csrf

  # Logger for Gnrd app
  class GnrdLogger < ::Logger
    alias write <<
  end

  log = GnrdLogger.new(__dir__ + "/log/sinatra.log")
  use Rack::CommonLogger, log
  use Rack::MethodOverride
  use Rack::Session::Cookie, secret: Gnrd.conf.session_secret
end
