# frozen_string_literal: true

# Performs name finding and resolution
module NameFinderWorker
  class << self
    def find_names(nf)
      nf.timeline = { start: Time.now.to_f }
      prepare_text(nf)
      prepare_names(nf)
      prepare_result(nf)
    rescue Gnrd::Error => e
      nf.add_error(e)
    ensure
      nf.state = :finished
      nf.save!
    end

    private

    def prepare_text(nf)
      nf.text = ResultBuilder.init_text(nf)
      nf.text.text_norm
      nf.timeline[:text_extraction] = Time.now.to_f
    end

    def prepare_names(nf)
      nf.names = Gnrd::GnfinderEngine.new(nf.text.dossier, nf.params)
                                     .find_resolve
      nf.timeline[:name_finding] = Time.now.to_f
      nf.save!
    end

    def prepare_result(nf)
      nf.result = ResultBuilder.init_gnfinder_result(nf)
      nf.timeline[:stop] = Time.now.to_f
      nf.result[:timeline] = nf.timeline
      nf.output.merge! OutputBuilder.add_result(nf)
    end
  end
end
