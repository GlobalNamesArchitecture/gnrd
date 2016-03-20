module Sinatra
  module Gnrd
    module Redirector
      URLS = { 400 => { html: "/" } }
      def redirect_url(status_code, format)
        url = URLS[status_code] && URLS[status_code][format]
        url
      end
    end
  end
end
