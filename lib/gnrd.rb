require_relative "../environment"
require_relative "gnrd/version"
require_relative "gnrd/errors"
require_relative "gnrd/source"
require_relative "gnrd/text_extractor"
require_relative "gnrd/info_file"
require_relative "gnrd/info_text"

# Namespace module for Global Names Recognition and Discovery
module Gnrd
  ENCODINGS = %w(UTF-8 UTF-16 ASCII ISO-8859-1 UNKNOWN).freeze
  FM = FileMagic.new
end
