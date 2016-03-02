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
      return @text if @text
      @text = case @file_type
              when "pdf"
                extract_pdf
              else
                docsplit
              end
    end

    private

    def extract_pdf
      docsplit(pages: "all")
    end

    def docsplit(opts = {})
      content = ""
      options = { output: @dir, clean: true }.merge(opts)
      Docsplit.extract_text(@path, options)
      Dir.entries(@dir).each do |f|
        if f =~ /\.txt$/
          f_path = File.join(@dir, f)
          content << File.read(f_path)
        end
      end
      content
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
