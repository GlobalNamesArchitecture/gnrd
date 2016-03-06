require "coveralls"
Coveralls.wear!

require "rack/test"
require "capybara"
require "capybara/rspec"
require "capybara/dsl"

ENV["RACK_ENV"] = "test"
require_relative "../application.rb"

require_relative "support/shared_context"

Capybara.app = Sinatra::Application

RSpec.configure do |c|
  c.include Capybara::DSL
end
