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
      set_orig
      @dossier.text[:orig]
    end

    def text_norm
      @dossier.text[:norm] ||= norm
    end

    private

    def set_orig
      txt = dossier.text[:orig]
      txt = Gnrd::SourceFactory.inst(dossier).text unless txt
      update_dossier(txt)
      dossier.text[:orig] =
        txt.force_encoding(@dossier.text[:encoding])
    end

    def update_dossier(txt)
      enc = CharDet.detect(txt)
      @dossier.text[:magic] = FileMagic.new.buffer(txt)
      @dossier.text[:encoding] =
        enc["encoding"] ? enc["encoding"].upcase : "UTF-8"
      @dossier.text[:encoding_confidence] = enc["confidence"]
    end

    def norm
      txt = text_orig
      txt = untag(txt) if html?
      opts = { invalid: :replace, undef: :replace }
      txt.encode("UTF-8", opts).tr("_", " ")
    end

    def html?
      @dossier.text[:magic].match(/\bHTML\b|\bXML\b/) != nil
    end

    # Removes html and xml tags
    def untag(txt)
      Sanitize.clean(txt).strip.gsub(/\s+/, " ")
    end
  end
end
