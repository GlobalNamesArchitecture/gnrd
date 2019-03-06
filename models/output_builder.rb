# frozen_string_literal: true

# Creates final output for name-finding result
class OutputBuilder
  ENGINES = %w[gnfinder gnfinder_no_bayes].freeze

  class << self
    def init(nf)
      params = prepare_params(nf)
      source = params.delete(:source)
      { token_url: "/name_finder#{extention(nf)}?token=#{nf.token}",
        input_url: source.delete(:url),
        file: source.delete(:file), status: 303,
        engine: params.delete(:out_engine), unique: params[:unique],
        verbatim: !params.delete(:unique),
        parameters: params }
    end

    def add_result(nf)
      res = { names: prepare_names(nf),
              status: 200,
              language_used: nf.names.language,
              execution_time: execution_time(nf), content: content(nf) }
      if nf.names.detect_language
        res[:language_detected] = nf.names.language_detected
      end
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
      params[:out_engine] = out_engine(params[:engine])
      if params[:source] && params[:source][:file]
        params[:source][:file] = params[:source][:file][:filename]
      end
      params.delete(:format)
      params
    end

    def prepare_names(nf)
      names = nf.names.names.each_with_object([]) do |n, ns|
        ns << build_gnfinder_name(n)
      end
      unique_names = names.map do |n|
        { scientificName: n[:scientificName] }
      end.uniq
      nf.params[:unique] ? unique_names : names
    end

    def build_gnfinder_name(name)
      {
        verbatim: name.verbatim,
        scientificName: name.name,
        offsetStart: name.offset_start,
        offsetEnd: name.offset_end
      }
    end

    def format(nf)
      nf.params[:format].to_sym
    end

    def execution_time(nf)
      tl = nf.result[:timeline]
      res = { text_preparation_duration: text_preparation(tl),
              find_names_duration: find_names(tl),
              total_duration: total(tl) }
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

    def out_engine(num)
      case num
      when 0
        ENGINES[0]
      when 1
        ENGINES[1]
      else
        ENGINES[0]
      end
    end

    def add_resolver_result(res, nf)
      verif = nf.names.names.each_with_object({}) do |n, m|
        next if m[n.name] || !n.verification

        m[n.name] = verif_gnfinder(n)
      end
      return if verif.empty?

      res[:verified_names] = verif.each_with_object([]) do |(k, v), m|
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
      br = v.best_result
      {
        is_known_name: br.match_type == :EXACT,
        data_sources_number: v.data_sources_num,
        in_curated_sources: v.data_source_quality,
        results: {
          match_value: br.match_type,
          name_string: br.matched_name,
          current_name_string: br.current_name,
          data_source_id: br.data_source_id,
          data_source_title: br.data_source_title,
          classification_path: br.classification_path,
          edit_distance: br.edit_distance
        },
        preferred_results: v.preferred_results.each_with_object([]) do |r, ary|
          ary << {
            data_source_id: r.data_source_id,
            data_source_title: r.data_source_title,
            taxon_id: r.taxon_id,
            name: n.name,
            matched_name: r.matched_name,
            matched_canonical: r.matched_canonical,
            current_name: r.current_name,
            classification_path: r.classification_path,
            classification_rank: r.classification_rank,
            classification_ids: r.classification_ids,
            match_type: r.match_type
          }
        end
      }
    end
  end
end
