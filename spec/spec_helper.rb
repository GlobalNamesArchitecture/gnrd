require 'rack/test'
require 'ruby-prof'
require_relative '../application.rb'

module RSpecMixin
  include Rack::Test::Methods
  def app() GNRD end
end

def profile_start
  RubyProf.start
end

def profile_end
  result = RubyProf.stop
  printer = RubyProf::FlatPrinter.new(result)
  printer.print(STDOUT, :min_percent => 0)
end

RSpec.configure { |c| c.include RSpecMixin }
