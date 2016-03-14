module Gnrd
  # Finds scientific names in texts
  class NameFinderEngine
    attr_reader :dossier, :options, :execution_time

    def initialize(dossier, opts = {})
      @dossier = dossier
      Gnrd::Text.new(dossier).text_norm unless dossier.text[:norm]
      @options = { netineti: true, taxonfinder: true }.merge(opts)
      @nn = neti_neti_engine
      @tf = taxon_finder_engine
      @execution_time = nil
    end

    def find
      start = Time.now
      res = find_raw
      @execution_time = Time.now - start
      res
    end

    private

    def find_raw
      names = {}
      taxon_finder_names(names)
      netineti_names(names)
      NamesCollection.new(names)
    end

    def taxon_finder_names(names)
      if options[:taxonfinder]
        names[:tf] = @tf.find(dossier.text[:norm])[:names]
        names[:tf].each { |i| i[:scientificName].gsub!(/\[[^()]*\]/, ".") }
      end
    end

    def netineti_names(names)
      names[:nn] = @nn.find(dossier.text[:norm])[:names] if options[:netineti]
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