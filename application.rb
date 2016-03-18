require "rack-timeout"
require "sinatra"
require "sinatra/base"
require "sinatra/flash"
require "sinatra/redirect_with_flash"
require "tilt/haml"
require "tilt/sass"

require_relative "lib/gnrd"
require_relative "models/name_finder"
require_relative "routes"
require_relative "helpers"
require_relative "lib/gnrd/app/formatter"
require_relative "lib/gnrd/app/params"

configure do
  register Sinatra::Flash
  helpers Sinatra::RedirectWithFlash

  enable :sessions

  use Rack::Timeout
  Rack::Timeout.timeout = 9_000_000

  set :haml, format: :html5
  set :protection, except: :json_csrf

  use Rack::MethodOverride
  use Rack::Session::Cookie, secret: Gnrd.conf.session_secret
end
