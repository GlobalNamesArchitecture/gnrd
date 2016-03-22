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
        text =
          begin
            RestClient.get(input_type.last)
          rescue RestClient::ExceptionWithResponse
            ""
          end
        Gnrd::Dossier.new(text: { orig: text })
      when :file
        Gnrd::Dossier.new(file: { path: Gnrd.file_path(input_type.last) })
      end
    end
  end
end
