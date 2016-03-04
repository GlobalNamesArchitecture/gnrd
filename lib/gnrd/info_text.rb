module Gnrd
  # Collects information about a text
  class InfoText
    attr_reader :info

    TEMPLATE = {
      file: false, magic: nil, type: nil,
      text: { orig: nil, norm: nil, encoding: nil }
    }.freeze

    def self.encoding(magic_value)
      raise(TypeError) unless magic_value.class == String
      case magic_value
      when /\bASCII\b/ then    "ASCII"
      when /\bUTF-8\b/ then    "UTF-8"
      when /\bUTF-16\b/ then   "UTF-16"
      when /\bISO-8859\b/ then "ISO-8859-1"
      else                     "UNKNOWN"
      end
    end

    def initialize(txt)
      raise(TypeError, "Not a string: #{txt}") unless txt.is_a?(String)
      @info = TEMPLATE.dup
      @info[:magic] = FM.buffer(txt)
      @info[:text][:orig] = txt
      @info[:text][:encoding] = InfoText.encoding(@info[:magic])
    end
  end
end
