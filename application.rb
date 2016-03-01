require "rack-timeout"
require "sinatra"
require "sinatra/base"
require "sinatra/flash"
require "sinatra/redirect_with_flash"
require "haml"
require "sass"

require_relative "lib/gnrd"
require_relative "routes"
require_relative "helpers"

configure do
  register Sinatra::Flash
  helpers Sinatra::RedirectWithFlash

  use Rack::MethodOverride
  use Rack::Session::Cookie, secret: Gnrd.conf.session_secret
  use Rack::Timeout
  Rack::Timeout.timeout = 9_000_000
end
