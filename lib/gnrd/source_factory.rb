module Gnrd
  # Analyses type of a file and creates corresponding source class
  module SourceFactory
    def self.factory(path)
      raise(Gnrd::FileMissingError) unless File.exist?(path)
      case FM.file(path)
      when RE_UTF8
        Gnrd::TextFile.new(path)
      when RE_PDF
        Gnrd::PdfFile.new(path)
      when RE_IMAGE
        Gnrd::ImageFile.new(path)
      else
        raise TypeError
      end
    end
  end
end
