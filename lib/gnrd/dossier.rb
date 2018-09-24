# frozen_string_literal: true

module Gnrd
  # Keeps data collected about a file or a string
  class Dossier
    def initialize(info = {})
      @file = info[:file] || {}
      @text = info[:text] || {}
    end

    def file(info = {})
      return @file if info.empty?

      @file.merge!(info)
    end

    def text(info = {})
      return @text if info.empty?

      @text.merge!(info)
    end
  end
end
