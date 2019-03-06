# frozen_string_literal: true

module Sinatra
  # Creates a DSL method for combining get and post requests with the same body
  module PostGet
    def post_get(route, &block)
      get(route, &block)
      post(route, &block)
    end
  end
end

register Sinatra::PostGet
