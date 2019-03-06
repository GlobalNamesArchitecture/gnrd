# frozen_string_literal: true

module Gnrd
  # Finds scientific names in texts using gnfinder project
  class GnfinderEngine
    attr_reader :dossier, :opts

    def initialize(dossier, params)
      @dossier = dossier
      @opts = gen_opts(params)
      Gnrd::Text.new(dossier).text_norm unless dossier.text[:norm]
      @gnf = Gnfinder::Client.new(Gnrd.conf.gnfinder_host,
                                  Gnrd.conf.gnfinder_port.to_s)
    end

    def find_resolve
      @gnf.find_names(dossier.text[:norm], @opts)
    end

    private

    # gen_opts(params) generates parameters recognizable by gRPC server of
    # gnfinder
    def gen_opts(params)
      opts = {}
      opts[:no_bayes] = params[:no_bayes]
      opts[:detect_language] = params[:detect_language]
      opts[:sources] = params[:preferred_data_sources]
      if params[:with_verification] || !opts[:sources].empty?
        opts[:verification] = true
      end
      opts
    end
  end
end
