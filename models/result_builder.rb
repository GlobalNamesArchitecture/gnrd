# Organizes results of name-finding
class ResultBuilder
  class << self
    def init_text(nf)
      return {} if nf.params[:source].empty?
      dossier = prepare_dossier(nf)
      Gnrd::Text.new(dossier)
    end

    def init_result(nf)
      { file: nf.text.dossier.file, text: nf.text.dossier.text,
        names: nf.names.combined }
    end

    private

    def prepare_dossier(nf)
      input_type = nf.params[:source].first
      case input_type.first
      when :text
        Gnrd::Dossier.new(text: { orig: input_type.last })
      when :url
        Gnrd::Dossier.new(text: { orig: from_url(input_type.last) })
      when :file
        Gnrd::Dossier.new(file: { path: input_type.last[:tempfile] })
      end
    end

    def from_url(url)
      url =~ %r{^http[s]?://} ? url : "http://" + url
      RestClient.get(url)
    rescue RestClient::ResourceNotFound
      raise Gnrd::UrlNotFoundError, "URL resource not found"
    end
  end
end
