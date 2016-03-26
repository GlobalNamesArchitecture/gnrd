# Creates final output for name-finding result
class OutputBuilder
  ENGINES = %w(TaxonFinder NetiNeti).freeze

  class << self
    def init(nf)
      params = prepare_params(nf)
      source = params.delete(:source)
      { token_url: "/name_finder#{format(nf)}?token=#{nf.token}",
        input_url: source.delete(:url),
        file: source.delete(:file), status: 303,
        engines: params.delete(:engines), unique: params[:unique],
        verbatim: !params.delete(:unique),
        parameters: params }
    end

    def add_result(nf)
      res = { names: prepare_names(nf), english_detected: nf.text.english?,
              engines: update_engines(nf), status: 200,
              execution_time: execution_time(nf), content: content(nf),
              resolved_names: resolved_names(nf) }
      res[:total] = res[:names].count
      res.select { |_, v| v }
    end

    private

    def content(nf)
      nf.params[:return_content] ? nf.text.text_norm : nil
    end

    def prepare_params(nf)
      params = Marshal.load Marshal.dump(nf.params)
      params[:engines] = engines(params[:engine])
      if params[:source][:file]
        params[:source][:file] = params[:source][:file][:filename]
      end
      params.delete(:format)
      params
    end

    def prepare_names(nf)
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
      res = {
        text_preparation_duration: text_preparation(tl),
        find_names_duration: find_names(tl),
        total_duration: total(tl) }
      res[:resolve_names_duration] = resolve_names(tl) if nf.result[:resolver]
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
        ENGINES
      when 1
        [ENGINES[0]]
      when 2
        [ENGINES[1]]
      end
    end

    def update_engines(nf)
      return nil unless nf.params[:detect_language] && nf.text.english? == false
      [ENGINES[0]]
    end

    def resolved_names(nf)
      nf.result[:resolver] ? res[:resolved_names] = nf.result[:resolver] : nil
    end
  end
end
