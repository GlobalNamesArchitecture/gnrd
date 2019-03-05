# frozen_string_literal: true

# Creates final output for name-finding result
class OutputBuilder
  ENGINES = %w[TaxonFinder NetiNeti GlobalNamesFinder].freeze

  class << self
    def init(nf)
      params = prepare_params(nf)
      source = params.delete(:source)
      { token_url: "/name_finder#{extention(nf)}?token=#{nf.token}",
        input_url: source.delete(:url),
        file: source.delete(:file), status: 303,
        engines: params.delete(:engines), unique: params[:unique],
        verbatim: !params.delete(:unique),
        parameters: params }
    end

    def add_result(nf)
      res = { names: prepare_names(nf), english_detected: nf.text.english?,
              engines: update_engines(nf), status: 200,
              execution_time: execution_time(nf), content: content(nf) }
      add_resolver_result(res, nf)
      res[:total] = res[:names].count
      res.select { |_, v| v }
    end

    private

    def extention(nf)
      nf.params[:format] == :html ? "" : ".#{nf.params[:format]}"
    end

    def content(nf)
      nf.params[:return_content] ? nf.text.text_norm : nil
    end

    def prepare_params(nf)
      params = Marshal.load Marshal.dump(nf.params)
      params[:engines] = engines(params[:engine])
      if params[:source] && params[:source][:file]
        params[:source][:file] = params[:source][:file][:filename]
      end
      params.delete(:format)
      params
    end

    def gnfinder?(nf)
      nf.params[:engine] == 3
    end

    def prepare_names(nf)
      names = if gnfinder?(nf)
                prepare_gnfinder_names(nf)
              else
                prepare_tf_nn_names(nf)
      end
      unique_names = names.map do |n|
        { scientificName: n[:scientificName] }
      end.uniq
      nf.params[:unique] ? unique_names : names
    end

    def prepare_gnfinder_names(nf)
      nf.names.each_with_object([]) do |n, names|
        names << build_gnfinder_name(n)
      end
    end

    def build_gnfinder_name(name)
      {
        verbatim: name.verbatim,
        scientificName: name.name,
        offsetStart: name.offset_start,
        offsetEnd: name.offset_end
      }
    end

    def prepare_tf_nn_names(nf)
      nf.result[:names].map do |n|
        n.delete(:engine)
        n
      end
    end

    def format(nf)
      nf.params[:format].to_sym
    end

    def execution_time(nf)
      tl = nf.result[:timeline]
      res = { text_preparation_duration: text_preparation(tl),
              find_names_duration: find_names(tl),
              total_duration: total(tl) }
      if nf.result[:resolved_names] && !gnfinder?(nf)
        res[:names_resolution_duration] = resolve_names(tl)
      end
      res
    end

    def text_preparation(tl)
      tl[:text_extraction] - tl[:start]
    end

    def find_names(tl)
      tl[:name_finding] - tl[:text_extraction]
    end

    def total(tl)
      tl[:stop] - tl[:start]
    end

    def resolve_names(tl)
      tl[:stop] - tl[:name_finding]
    end

    def engines(num)
      case num
      when 0
        ENGINES[0..1]
      when 1
        [ENGINES[0]]
      when 2
        [ENGINES[1]]
      when 3
        [ENGINES[2]]
      end
    end

    def update_engines(nf)
      return nil if gnfinder?(nf)
      return nil unless nf.params[:detect_language] && nf.text.english? == false
      [ENGINES[0]]
    end

    def add_resolver_result(res, nf)
      return add_resolver_results_gnfinder(res, nf) if gnfinder?(nf)

      return unless nf.result[:resolved_names]
      add_resolver_results_tf_nn(res, nf)
    end

    def add_resolver_results_gnfinder(res, nf)
      verif = nf.names.each_with_object({}) do |n, m|
        next if m[n.name] || !n.verification
        m[n.name] = verif_gnfinder(n)
      end
      return if verif.empty?
      res[:resolved_names] = verif.each_with_object([]) do |(k, v), m|
        m << {
          supplied_name_string: k,
          is_known_name: v[:is_known_name],
          results: v[:results],
          preferred_results: v[:preferred_results]
        }
      end
    end

    def verif_gnfinder(n)
      v = n.verification
      {
        is_known_name: v.match_type == :EXACT,
        data_sources_number: v.data_sources_num,
        in_curated_sources: v.data_source_quality,
        results: {
          match_value: v.match_type,
          name_string: v.matched_name,
          current_name_string: v.current_name,
          data_source_id: v.data_source_id,
          data_source_title: v.data_source_title,
          classification_path: v.classification_path,
          edit_distance: v.edit_distance
        },
        preferred_results: v.preferred_results.each_with_object([]) do |r, ary|
          ary << {
            data_source_id: r.data_source_id,
            data_source_title: r.data_source_title,
            name_id: r.name_id,
            name: r.name,
            taxon_id: r.taxon_id
          }
        end
      }
    end

    def add_resolver_results_tf_nn(res, nf)
      return unless nf.result[:resolved_names]

      res[:resolved_names] = nf.result[:resolved_names]
      res[:data_sources] = nf.result[:data_sources]
    end
  end
end
