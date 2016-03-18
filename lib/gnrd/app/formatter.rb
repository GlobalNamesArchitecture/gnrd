module Gnrd
  module App
    # JSON format for output
    class FormatJson
      def initialize(name_finder)
        @nf = name_finder
      end

      def show
        res = { params: @nf.params, text: @nf.text, output: @nf.output }
        status @nf.status_code
        content_type "application/json", charset: "utf-8"
        JSON.dump(res)
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

      def show
        # haml :fail
      end
    end

    # Sets formatting environment for name finder output
    class Formatter
      FORMAT = { "json" => Gnrd::App::FormatJson,
                 "xml"  => Gnrd::App::FormatXml }.freeze

      def initialize(name_finder)
        @nf = name_finder
        @format = FORMAT[name_finder.params[:format]] ||
                  Gnrd::App::FormatHtml
      end

      def show
        if @nf.redirect_path
          redirect @nf.redirect_path
          @nf.redirect_path = nil
        end
        @format.new(@nf).show
      end
    end
  end
end
