# frozen_string_literal: true

module Gnrd
  # Tries to figure out a file type
  class FileInspector
    class << self
      def info(path)
        unless path.is_a?(String)
          raise(TypeError.new("File path is not string: #{path}"))
        end

        unless File.exist?(path)
          raise(Gnrd::FileMissingError.new("No such file: #{path}"))
        end

        collect_info(path)
      end

      private

      def collect_info(path)
        magic = FileMagic.new.file(path)
        magic = "Microsoft Excel" if excel_file?(path, magic)
        { magic: magic, type: file_type(magic) }
      end

      def excel_file?(path, magic)
        magic =~ /\bMicrosoft OOXML/ && path =~ /\.xlsx$/
      end

      def file_type(magic)
        case magic
        when /\bHTML\b/ then            "html_file"
        when /\bPDF\b/ then             "pdf_file"
        when /\bimage data\b/ then      "image_file"
        when /\bMicrosoft Word\b/ then  "msword_file"
        when /\bMicrosoft Excel\b/ then "msexcel_file"
        when /\b(text|FORTRAN)\b/ then  "text_file"
        else                            "unknown_file"
        end
      end
    end
  end
end
