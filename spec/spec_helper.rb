# frozen_string_literal: true

require "coveralls"
Coveralls.wear!

require "rack/test"
require "capybara"
require "capybara/rspec"
require "capybara/dsl"
require "factory_bot"
require "json"

ENV["RACK_ENV"] = "test"
require_relative "../application"
require_relative "support/shared_context"

Capybara.app = Sinatra::Application

# required for RackTest
def app
  Sinatra::Application
end

RSpec.configure do |c|
  c.include Capybara::DSL
  c.include Rack::Test::Methods
end
