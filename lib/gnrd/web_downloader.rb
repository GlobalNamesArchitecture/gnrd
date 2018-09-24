# frozen_string_literal: true

module Gnrd
  # Downloads files from internet urls
  class WebDownloader
    def download(url, filename)
      test(url)
      path = file_path(filename, url)
      f = File.open(path, "w")
      resp = RestClient.get(url)
      f.write(resp.body)
      f.close
      path
    rescue RestClient::ExceptionWithResponse => err
      raise Gnrd::UrlRetrievalError.new(err.response.code)
    end

    private

    def test(url)
      req = RestClient::Request.new(method: :head, url: url, timeout: 2)
      resp = req.execute
      raise Gnrd::UrlRetrievalError.new(resp.code) if resp.code >= 400
    rescue RestClient::Exceptions::Timeout
      raise Gnrd::UrlRetrievalError.new(408)
    rescue SocketError
      raise Gnrd::UrlRetrievalError.new(443)
    rescue RestClient::SSLCertificateNotVerified
      raise Gnrd::UrlRetrievalError.new(526)
    end

    def file_path(filename, url)
      ext = Addressable::URI.parse(url).extname
      "#{Gnrd.dir}/#{filename}#{ext}"
    end
  end
end
