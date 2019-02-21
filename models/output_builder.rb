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
      if gnfinder?(nf)
        prepare_gnfinder_names(nf)
      else
        prepare_tf_nn_names(nf)
      end
    end

    def prepare_gnfinder_names(nf)
      names = []
      nf.names.each do |n|
        names << build_gnfinder_name(n)
      end
      names
    end

    def build_gnfinder_name(name)
      {
        verbatim: name.verbatim,
        scientificName: name.name,
        offsetStart: name.offset_start,
        offsetEnd: name.offset_end,
      }
    end

    def prepare_tf_nn_names(nf)
      names = nf.result[:names].map do |n|
        n.delete(:engine)
        n
      end
      unique_names = names.map do |n|
        { scientificName: n[:scientificName] }
      end.uniq
      nf.params[:unique] ? unique_names : names
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
      return unless nf.result[:resolved_names]

      res[:resolved_names] = nf.result[:resolved_names]
      res[:data_sources] = nf.result[:data_sources]
    end
  end
end
