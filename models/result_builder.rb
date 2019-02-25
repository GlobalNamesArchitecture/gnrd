# frozen_string_literal: true

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

    def init_gnfinder_result(nf)
      { file: nf.text.dossier.file, text: nf.text.dossier.text }
    end

    private

    def prepare_dossier(nf)
      input_type = nf.params[:source].first
      case input_type.first
      when :text
        Gnrd::Dossier.new(text: { orig: input_type.last })
      when :url, :file
        Gnrd::Dossier.new(file: { path: nf.params[:file_path] })
      end
    end
  end
end
