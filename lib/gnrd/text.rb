module Gnrd
  # Holds all information about a text to be used for name finding
  # and the source of the text
  class Text
    attr_reader :dossier

    def self.normalize(txt)
      opts = { invalid: :replace, undef: :replace }
      enc = CharDet.detect(txt)
      txt = txt.encode("UTF-8", enc["encoding"], opts)
      [txt, enc]
    end

    def initialize(dossier)
      unless dossier.is_a? Gnrd::Dossier
        raise TypeError, "Needs Gnrd::Dossier to init"
      end
      @dossier = dossier
    end

    def text_orig
      @dossier.text[:orig] ||= orig
    end

    private

    def orig
      Gnrd::SourceFactory.inst(@dossier).text
    end

    def prepare_text
      txt = @dossier[:text][:orig]
      @dossier[:text][:norm], @dossier[:text][:encoding] =
        TextString.normalize(txt, is_utf8)
      @dossier[:text][:norm]
    end
  end
end
