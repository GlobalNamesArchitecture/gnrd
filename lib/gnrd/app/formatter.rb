module Gnrd
  module App
    # Sets formatting environment for name finder output
    class Formatter
      def initialize(name_finder, opts)
        @nf = name_finder
        @opts = {}.merge(opts) if opts
      end
    end
  end
end
