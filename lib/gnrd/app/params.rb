module Gnrd
  module App
    # Normalizes parameters entered via API or User Interface
    class Params
      attr_reader :params

      def initialize(params)
        @params = params
      end

      def normalize
        res = { source: params_sources }
        res.merge! params_boolean
        res.merge! params_data_sources
        res[:detect_language] = detect_language?
        res[:format] = normalize_format
        res[:engine] = normalize_engine
        params.merge(res)
      end

      private

      def params_sources
        %i(url file text).each_with_object({}) do |p, obj|
          v =  params.delete(p) || (params[:find] && params[:find].delete(p))
          obj[p] = v if v
        end
      end

      def params_boolean
        %i(unique verbatim return_content all_data_sources best_match_only)
          .each_with_object({}) do |p, obj|
          obj[p] = params[p] ? true : false
        end
      end

      def normalize_format
        fmt = params[:format] ? params[:format].strip : "html"
        %w(json xml html).include?(fmt) ? fmt : "html"
      end

      def detect_language?
        dt = params[:detect_language] ||
             (params[:find] && params[:find][:detect_language])
        dt.to_s.strip == "false" ? false : true
      end

      def params_data_sources
        %i(data_source_ids preferred_data_sources)
          .each_with_object({}) do |p, obj|
          if params[p]
            normalize_data_source(obj, p, params[p])
            obj[p] = obj[p].map(&:to_i).uniq.compact
          end
        end
      end

      def normalize_data_source(hsh, key, value)
        hsh[key] = value.is_a?(Array) ? value : value.split("|")
      end

      def normalize_engine
        engine = params[:engine].to_i
        (1..2).cover?(engine) ? engine : 0
      end
    end
  end
end
