module Gnrd
  # Finds scientific names in texts
  class NameFinder
    attr_reader :dossier, :options

    def initialize(dossier, opts = {})
      @dossier = dossier
      Gnrd::Text.new(dossier).text_norm unless dossier.text[:norm]
      @options = { netineti: true, taxonfinder: true }.merge(opts)
      @nn = neti_neti_engine
      @tf = taxon_finder_engine
    end

    def find
      names = {}
      names[:nn] = @nn.find(dossier.text[:norm]) if options[:netineti]
      names[:tf] = @tf.find(dossier.text[:norm]) if options[:taxonfinder]
      return names.values.first if names.size == 1
      combine_results(names)
    end

    private

    # TODO: add logic
    def combine_results(names)
      names
    end

    def taxon_finder_engine
      client = NameSpotter::TaxonFinderClient.new(
        host: Gnrd.conf.taxon_finder_host,
        port: Gnrd.conf.taxon_finder_port
      )
      NameSpotter.new(client)
    end

    def neti_neti_engine
      client = NameSpotter::NetiNetiClient.new(
        host: Gnrd.conf.neti_neti_host,
        port: Gnrd.conf.neti_neti_port
      )
      NameSpotter.new(client)
    end
  end
end
