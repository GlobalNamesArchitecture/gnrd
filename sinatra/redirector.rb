module Sinatra
  module Gnrd
    # Finds if where to redirect, if needed
    module Redirector
      URLS = { 400 => { html: "/" } }.freeze
      def redirect_url(status_code, format)
        url = URLS[status_code] && URLS[status_code][format]
        url
      end
    end
  end
end
