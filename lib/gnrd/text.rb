module Gnrd
  # Holds all information about a text to be used for name finding
  # and the source of the text
  class Text
    attr_reader :dossier

    def initialize(dossier)
      unless dossier.is_a? Gnrd::Dossier
        raise TypeError, "Needs Gnrd::Dossier to init"
      end
      @dossier = dossier
    end

    def text_orig
      @dossier.text[:orig] ||= orig
    end

    def text_norm
      @dossier.text[:norm] ||= norm
    end

    private

    def orig
      Gnrd::SourceFactory.inst(@dossier).text
    end

    def norm
      opts = { invalid: :replace, undef: :replace }
      enc = CharDet.detect(text_orig)
      @dossier.text[:encoding] = enc["encoding"]
      @dossier.text[:encoding_confidence] = enc["confidence"]
      text_orig.encode("UTF-8", enc["encoding"], opts)
    end
  end
end
