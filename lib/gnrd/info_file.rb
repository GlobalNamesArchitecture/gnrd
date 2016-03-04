module Gnrd
  # Tries to figure out a file type and encoding class InfoFile
  class InfoFile
    attr_reader :info

    def initialize(path)
      raise(TypeError,
            "File path is not string: #{path}") unless path.is_a?(String)
      raise(Gnrd::FileMissingError,
            "No such file: #{path}") unless File.exist?(path)
      @info = Gnrd::InfoText::TEMPLATE.dup.merge(file: path)
      collect_info
    end

    private

    def collect_info
      @info[:magic] = Gnrd::FM.file(info[:file])
      add_type
      send(@info[:type])
    end

    def add_type
      @info[:type] =
        case @info[:magic]
        when /\bHTML\b/ then       "html_file"
        when /\bPDF\b/ then        "pdf_file"
        when /\bimage data\b/ then "image_file"
        when /\btext\b/ then       "text_file"
        else                       "unknown_file"
        end
    end

    def text_file
      @info[:text][:encoding] = InfoText.encoding(@info[:magic])
    end
    alias html_file text_file

    def pdf_file; end

    def image_file; end

    def unknown_file; end
  end
end
