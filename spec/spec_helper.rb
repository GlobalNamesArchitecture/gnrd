require 'coveralls'
Coveralls.wear!

# HACK: to suppress warnings
$VERBOSE = nil

require 'rack/test'
require 'capybara'
require 'capybara/rspec'
require 'capybara/dsl'
require 'capybara/webkit'
require 'byebug'
require_relative 'support/helpers'

ENV['RACK_ENV'] = 'test'
require_relative '../application.rb'

Capybara.javascript_driver = :webkit
Capybara.app = Sinatra::Application

RSpec.configure do |c|
  c.include Capybara::DSL
end
