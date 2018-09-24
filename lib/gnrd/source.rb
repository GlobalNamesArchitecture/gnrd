# frozen_string_literal: true

module Gnrd
  # Abstract class for sources
  class Source
    def initialize(dossier)
      @dossier = dossier
    end

    def text
      @text ||= text_raw
    end

    private

    def text_raw
      File.read(@dossier.file[:path], encoding: "utf-8")
    end
  end

  # Data source of a text-file type. The file should be in utf-8 encoding
  class TextFile < Source
  end

  # Data source of html-file type
  class HtmlFile < Source
  end

  # Data source of a pdf-file type. The text should be in utf-8 encoding
  class PdfFile < Source
    def text_raw
      TextExtractor.new(@dossier.file[:path]).text
    end
  end

  # Data source of an image-file type.
  class ImageFile < Source
    def text_raw
      TextExtractor.new(@dossier.file[:path]).text
    end
  end

  # Data source of a msword-file type.
  class MswordFile < Source
    def text_raw
      TextExtractor.new(@dossier.file[:path]).text
    end
  end

  # Data source of a msexcel-file type.
  class MsexcelFile < Source
    def text_raw
      TextExtractor.new(@dossier.file[:path]).text
    end
  end

  # Data source of unknown-file type
  class UnknownFile < Source
    def text_raw
      ""
    end
  end
end
