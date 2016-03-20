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
require_relative "models/errors"
require_relative "models/name_finder"

require_relative "sinatra/formatter"
require_relative "sinatra/redirector"
require_relative "helpers"
require_relative "routes"

configure do
  register Sinatra::Flash
  helpers Sinatra::RedirectWithFlash,
    Sinatra::Gnrd::Redirector

  enable :sessions

  use Rack::Timeout
  Rack::Timeout.timeout = 9_000_000

  set :haml, format: :html5
  set :protection, except: :json_csrf

  use Rack::MethodOverride
  use Rack::Session::Cookie, secret: Gnrd.conf.session_secret
end
