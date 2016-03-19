module Sinatra
  # JSON format for output
  class FormatJson
    def initialize(name_finder)
      @nf = name_finder
    end

    def content_type
      "application/json; charset=UTF-8"
    end

    def render
      JSON.dump(hi: "hi")
    end
  end

  # XML format for output
  class FormatXml
  end

  # HTML format for output
  class FormatHtml
    def initialize(name_finder)
      @nf = name_finder
    end

    def content_type
      "text/html; charset=UTF-8"
    end

    def render
      eval("haml(:fail)")
    end
  end

  # Sets formatting environment for name finder output
  class Formatter
    FORMAT = { "json" => Sinatra::FormatJson,
               "xml"  => Sinatra::FormatXml }.freeze

    def initialize(name_finder)
      @nf = name_finder
      fmt = FORMAT[name_finder.params[:format]] ||
            Sinatra::FormatHtml
      @format = fmt.new(@nf)
    end

    def content_type
      @format.content_type
    end

    def render
      @format.render
    end
  end
end
