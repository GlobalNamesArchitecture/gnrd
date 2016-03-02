module Gnrd
  # The simplest source type: utf8-encoded string
  class TextString
    attr_reader :text

    def initialize(txt)
      @text = txt
      raise TypeError, "Not a utf-8 encoded string: #{@txt}" unless text_string?
    end

    private

    def text_string?
      @text.class == String && @text.encoding.name == "UTF-8"
    end
  end

  # Source of a text-file type. The file should be in utf-8 encoding
  class TextFile
    def initialize(path)
      @fm = FileMagic.new
      @path = path
      raise TypeError, "Not a utf-8 text file: #{@path}" unless text_file?
    end

    def text
      @text ||= File.read(@path)
    end

    private

    def text_file?
      File.exist?(@path) && @fm.file(@path).match(/(UTF-8|ASCII).+text/)
    end
  end

  # Source of a pdf-file type. The text should be in utf-8 encoding
  class PdfFile
    def initialize(path)
      @fm = FileMagic.new
      @path = path
      raise TypeError, "Not a PDF file: #{@path}" unless pdf_file?
    end

    def text
      @text ||= TextExtractor.new(@path, "pdf").text
    end

    private

    def pdf_file?
      File.exist?(@path) && @fm.file(@path).match(/PDF/)
    end
  end
end
