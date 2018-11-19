# frozen_string_literal: true

module Gnrd
  # Finds scientific names in texts using gnfinder project
  class GnfinderEngine
    attr_reader :dossier, :opts
    def initialize(dossier, params)
      @dossier = dossier
      @opts = gen_opts(params)
      require 'byebug'; byebug
      Gnrd::Text.new(dossier).text_norm unless dossier.text[:norm]
      @gnf = Gnfinder::Client.new(Gnrd.conf.gnfinder_host,
                                  Gnrd.conf.gnfinder_port.to_s)
    end

    def find
      @gnf.find_names(dossier.text[:norm], @opts)
    end

    private

    def gen_opts(params)
      opts = {}
      opts[:language] = "eng" unless params[:detect_language]
      opts
    end
  end
end
