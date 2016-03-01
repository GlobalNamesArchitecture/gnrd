require 'coveralls'
Coveralls.wear!

require 'rack/test'
require 'capybara'
require 'capybara/rspec'
require 'capybara/dsl'

ENV['RACK_ENV'] = 'test'
require_relative '../application.rb'

Capybara.app = Sinatra::Application

RSpec.configure do |c|
  c.include Capybara::DSL
end
