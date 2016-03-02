require_relative "../environment"
require_relative "gnrd/version"
require_relative "gnrd/errors"
require_relative "gnrd/source"
require_relative "gnrd/text_extractor"
require_relative "gnrd/source_factory"

# Namespace module for Global Names Recognition and Discovery
module Gnrd
  FM = FileMagic.new
  RE_UTF8 = /(\bUTF-8\b|\bASCII\b).+text/
  RE_PDF = /\bPDF\b/
  RE_IMAGE = /\bimage data\b/
end
