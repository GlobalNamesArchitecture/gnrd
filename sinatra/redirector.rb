module Sinatra
  module Gnrd
    # Finds if where to redirect, if needed
    module Redirector
      URLS = { 400 => { html: "/" },
               303 => { json: "/name_finder.json?token=TOKEN",
                        xml: "/name_finder.xml?token=TOKEN",
                        html: "/name_finder?token=TOKEN" }
      }.freeze
      def redirect_url(status_code, formatter)
        frm = formatter
        token = frm.name_finder.token
        url = URLS[status_code] && URLS[status_code][frm.format]
        url ? url.gsub("TOKEN", token) : nil
      end
    end
  end
end
