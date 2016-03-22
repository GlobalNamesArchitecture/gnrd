module Gnrd
  # Finds scientific names in texts
  class NameFinderEngine
    attr_reader :dossier, :options, :execution_time
    ENGINES = {
      taxon_finder: { klass: NameSpotter::TaxonFinderClient,
                      host: Gnrd.conf.taxon_finder_host,
                      port: Gnrd.conf.taxon_finder_port },
      neti_neti:    { klass: NameSpotter::NetiNetiClient,
                      host: Gnrd.conf.neti_neti_host,
                      port: Gnrd.conf.neti_neti_port }
    }.freeze

    def initialize(dossier, opts = {})
      @dossier = dossier
      Gnrd::Text.new(dossier).text_norm unless dossier.text[:norm]
      @options = { netineti: true, taxonfinder: true }.merge(opts)
      @nn = neti_neti_engine
      @tf = taxon_finder_engine
    end

    def find
      names = {}
      taxon_finder_names(names)
      netineti_names(names)
      NamesCollection.new(names)
    end

    private

    def taxon_finder_names(names)
      if options[:taxonfinder]
        names[:tf] = @tf.find(dossier.text[:norm].dup)[:names]
        names[:tf].each { |i| i[:scientificName].gsub!(/\[[^()]*\]/, ".") }
      end
    end

    def netineti_names(names)
      if options[:netineti]
        names[:nn] = @nn.find(dossier.text[:norm].dup)[:names]
      end
    end

    def taxon_finder_engine
      engine_factory(ENGINES[:taxon_finder])
    end

    def neti_neti_engine
      engine_factory(ENGINES[:neti_neti])
    end

    def engine_factory(engine)
      client = engine[:klass].new(
        host: engine[:host],
        port: engine[:port]
      )
      NameSpotter.new(client)
    end
  end
end
