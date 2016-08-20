module Gnrd
  class Error < RuntimeError; end
  class FileMissingError < Gnrd::Error; end
  class UnknownEncodingError < Gnrd::Error; end
  class AbsentTextStringError < Gnrd::Error; end

  # Errors with http status code
  class UrlRetrievalError < Gnrd::Error
    attr_reader :status_code

    def initialize(status_code, message = nil)
      @status_code = status_code.to_i
      is_404 = (@status_code == 404)
      default_msg = is_404 ? "URL resource not found" : "URL retrieval error"
      super(message || default_msg)
    end
  end
end
