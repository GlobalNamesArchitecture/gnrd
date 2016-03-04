module Gnrd
  # The simplest source type: utf8-encoded string
  class TextString
    attr_reader :info

    def self.normalize(txt, encoding)
      unless ENCODINGS.include? encoding
        raise(Gnrd::UnknownEncoding, "We don't know about this: #{encoding}")
      end
      opts = { invalid: :replace, undef: :replace }
      case encoding
      when /UTF-8|UNKNOWN/ then txt.encode("UTF-8", opts)
      else txt.encode("UTF-8", encoding, opts)
      end
    end

    def initialize(txt)
      @info = InfoText.new(txt).info
    end

    def text
      @text ||= prepare_text
    end

    private

    def prepare_text
      txt = @info[:text][:orig]
      enc = @info[:text][:encoding]
      @info[:text][:norm] = TextString.normalize(txt, enc)
    end
  end

  # Data source of a text-file type. The file should be in utf-8 encoding
  class TextFile
    attr_reader :info

    def initialize(path)
      @info = Gnrd::InfoFile.new(path).info
      raise(TypeError,
            "Not a text file: #{path}") unless info[:type] == "text_file"
    end

    def text
      @text ||= prepare_text
    end

    private

    def prepare_text
      txt = File.read(@info[:file])
      enc = @info[:text][:encoding]
      txt.force_encoding!(enc) if enc != "UNKNOWN"
      @info[:text][:orig] = txt
      @info[:text][:norm] = TextString.normalize(txt, enc)
    end
  end

  # Data source of an HTML text string.
  class HtmlString
    def initialize(html)
      @html = html
    end

    def text
      @text ||= clean_text
    end

    def clean_text
      Sanitize.clean(@html).strip.gsub(/\s+/, " ")
    end
  end

  # Data source of html-file type
  class HtmlFile
    def initialize(path)
      @path = path
      raise(Gnrd::FileMissingError) unless File.exist?(path)
      @hs = HtmlString.new(File.read(@path))
    end

    def text
      @text ||= @hs.text
    end
  end

  # Data source of a pdf-file type. The text should be in utf-8 encoding
  class PdfFile
    attr_reader :info

    def initialize(path)
      @info = InfoFile.new(path).info
      unless info[:type] == "pdf_file"
        raise TypeError, "Not a PDF file: #{path}"
      end
    end

    def text
      @text ||= TextExtractor.new(@info[:file], "pdf").text
    end
  end

  # Data source of an image-file type.
  class ImageFile
    attr_reader :info

    def initialize(path)
      @info = Gnrd::InfoFile.new(path).info
      unless @info[:type] == "image_file"
        raise TypeError, "Not an image file: #{path}"
      end
    end

    def text
      @text ||= @info[:text][:norm] = TextExtractor.new(@info[:file]).text
    end
  end
end
