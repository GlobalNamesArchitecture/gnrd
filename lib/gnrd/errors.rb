module Gnrd
  class Error < RuntimeError; end
  class FileMissingError < Gnrd::Error; end
  class UnknownEncodingError < Gnrd::Error; end
  class AbsentTextStringError < Gnrd::Error; end
  class UrlNotFoundError < Gnrd::Error; end
end
