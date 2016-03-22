module Sinatra
  # JSON format for output
  class FormatJson
    def initialize(name_finder)
      @nf = name_finder
    end

    def content_type
      "application/json"
    end

    def content
      JSON.dump @nf.output
    end
  end

  # XML format for output
  class FormatXml
    def initialize(name_finder)
      @nf = name_finder
    end

    def content_type
      "text/xml"
    end

    def content
      @nf.output
    end
  end

  # HTML format for output
  class FormatHtml
    def initialize(name_finder)
      @nf = name_finder
    end

    def content_type
      "text/html; charset=UTF-8"
    end

    def content
      @nf.output
    end
  end

  # Sets formatting environment for name finder output
  class Formatter
    attr_reader :nf, :format
    alias name_finder nf

    FORMAT = { "html" => Sinatra::FormatHtml,
               "json" => Sinatra::FormatJson,
               "xml"  => Sinatra::FormatXml }.freeze

    def initialize(name_finder)
      @nf = name_finder
      @format = find_format
      fmt = FORMAT[@nf.params[:format]] || Sinatra::FormatHtml
      @formatter = fmt.new(@nf)
    end

    def content_type
      @formatter.content_type
    end

    def content
      @formatter.content
    end

    private

    def find_format
      if %w(html json xml).include?(@nf.params[:format].to_s)
        @nf.params[:format].to_sym
      else
        :html
      end
    end
  end
end
