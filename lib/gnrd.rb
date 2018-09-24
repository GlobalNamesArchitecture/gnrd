# frozen_string_literal: true

require_relative "../environment"
require_relative "gnrd/version"
require_relative "gnrd/errors"
require_relative "gnrd/dossier"
require_relative "gnrd/file_inspector"
require_relative "gnrd/text_extractor"
require_relative "gnrd/text"
require_relative "gnrd/source"
require_relative "gnrd/source_factory"
require_relative "gnrd/name_finder_engine"
require_relative "gnrd/names_collection"
require_relative "gnrd/resolver"
require_relative "gnrd/web_downloader"

# Namespace module for Global Names Recognition and Discovery
module Gnrd
  def self.today
    Time.new.strftime("%Y-%m-%d")
  end
end
