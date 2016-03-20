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

# Namespace module for Global Names Recognition and Discovery
module Gnrd
  def self.symbolize_keys(obj)
    case obj
    when Array
      obj.map { |v| symbolize_keys(v) }
    when Hash
      obj.each_with_object({}) do |(k, v), o |
        o[k] = symbolize_keys(v)
      end.symbolize_keys
    else
      obj
    end
  end
end
