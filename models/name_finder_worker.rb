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
      opts = find_names_opts(nf)
      nf.names = Gnrd::NameFinderEngine.new(nf.text.dossier, opts).find.combine
      nf.timeline[:name_finding] = Time.now.to_f
    end

    def prepare_result(nf)
      nf.result = ResultBuilder.init_result(nf)
      resolve_names(nf)
      nf.timeline[:stop] = Time.now.to_f
      nf.result[:timeline] = nf.timeline
      nf.output.merge! OutputBuilder.add_result(nf)
    end

    def resolve?(nf)
      nf.result[:names].any? &&
        (nf.params[:all_data_sources] || nf.params[:data_source_ids].any?)
    end

    def resolve_names(nf)
      return unless resolve?(nf)

      nf.result.merge!(Gnrd::Resolver.new(nf.result[:names], nf.params).resolve)
    end

    def find_names_opts(nf)
      opts = {}
      opts[:netineti] = false if nf.params[:engine] == 1
      opts[:taxonfinder] = false if nf.params[:engine] == 2
      adjust_opts_for_lang(nf, opts) if nf.params[:detect_language]
      opts
    end

    def adjust_opts_for_lang(nf, opts)
      opts.merge!(netineti: false) if nf.text.english? == false
    end
  end
end
