module Gnrd
  # Checks names qualilty using global names resolver
  class Resolver
    def initialize(names, opts)
      @names = names.map { |n| n[:scientificName] }.uniq
      @resolver = RestClient::Resource.new(Gnrd.conf.resolver_url,
                                           timeout: 9_000_000,
                                           open_timeout: 9_000_000,
                                           connection: "Keep-Alive")
      @params = prepare_params(opts)
    end

    def resolve
      res = resolve_names
      res ? output(res) : nil
    end

    private

    def output(res)
      if res[:data]
        { data_sources: res[:data_sources],
          resolved_names: res[:data] }
      end
    end

    def resolve_names
      res = @resolver.post @params
      JSON.parse(res, symbolize_names: true)
    rescue RuntimeError
      nil
    end

    def prepare_params(opts)
      res = { data: @names[0...1000].join("\n"), resolve_once: false,
              with_context: false, best_match_only: opts[:best_match_only],
              preferred_data_sources: opts[:preferred_data_sources].join("|") }
      if opts[:data_source_ids]
        res[:data_source_ids] = opts[:data_source_ids].join("|")
        res[:best_match_only] = opts[:best_match_only]
      end
      res
    end
  end
end
