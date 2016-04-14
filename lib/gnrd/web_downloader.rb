module Gnrd
  # Downloads files from internet urls
  class WebDownloader
    def initialize
      @agent = Mechanize.new
      @agent.user_agent_alias = "Linux Mozilla"
      @agent.pluggable_parser.default = Mechanize::Download
      @head = nil
    end

    def download(url, filename)
      @head = head(url)
      raise(Gnrd::UrlRetrievalError.new(@head.code)) if @head.code.to_i >= 400
      path = file_path(filename)
      @agent.get(url).save path
      path
    rescue Mechanize::Error => e
      status_code = e.respond_to?(:response_code) ? e.response_code : 200
      raise Gnrd::UrlRetrievalError.new(status_code)
    end

    private

    def head(url)
      @agent.head(url)
    rescue Mechanize::ResponseCodeError => e
      raise(Gnrd::UrlRetrievalError.new(e.response_code))
    rescue SocketError
      raise(Gnrd::UrlRetrievalError.new(404, "URL resource not found"))
    end

    def file_path(filename)
      ext = File.extname(@head.filename)
      "#{Gnrd.dir}/#{filename}#{ext}"
    end
  end
end
