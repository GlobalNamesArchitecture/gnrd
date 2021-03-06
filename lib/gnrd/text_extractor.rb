# frozen_string_literal: true

module Gnrd
  # Extracts texts from images, pdfs, and other binary files
  class TextExtractor
    def initialize(path)
      @path = path
      raise(FileMissingError) unless File.exist?(@path)

      @dir = make_dir
    end

    def text
      @text ||= docsplit
    end

    private

    def docsplit
      # { osr: true } option is not set, as docsplit should apply
      # ocr on its own when needed
      options = { output: @dir, clean: true }
      Docsplit.extract_text(@path, options)
      files = Dir.entries(@dir).select { |f| f =~ /\.txt$/ }
      assemble_text(files)
    end

    def assemble_text(files)
      return "" if files.empty?

      files = files.sort_by do |f|
        m = f.match(/\d+/)
        m ? m[0].to_i : 0
      end
      files.each_with_object([]) do |f, obj|
        obj << File.read(File.join(@dir, f))
      end.join("\n")
    end

    def dir_name
      dir_name = "docsplit-" + rand(100_000_000..999_999_999).to_s(16)
      File.join(Gnrd.conf.tmp_dir, dir_name)
    end

    def make_dir(dir_path = nil)
      loop do
        dir_path = dir_name
        break unless File.exist?(dir_path)
      end
      FileUtils.mkdir(dir_path)
      dir_path
    end
  end
end
