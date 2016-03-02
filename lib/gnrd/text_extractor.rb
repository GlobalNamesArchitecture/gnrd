module Gnrd
  # Extracts texts from images, pdfs, and other binary files
  class TextExtractor
    def initialize(file_type, path)
      @file_type = file_type
      @path = path
      raise(FileMissingError) unless File.exist?(@path)
      @dir = make_dir
    end

    def text
      @text ||= docsplit
    end

    private

    def docsplit(opts = {})
      options = { output: @dir, clean: true }.merge(opts)
      Docsplit.extract_text(@path, options)
      files = Dir.entries(@dir).select { |f| f =~ /\.txt$/ }
      assemble_text(files)
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
