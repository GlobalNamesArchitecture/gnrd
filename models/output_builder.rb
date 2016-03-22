class OutputBuilder
  ENGINES = ["TaxonFinder", "NetiNeti"].freeze

  class << self
    def init(nf)
      { token_url: "/name_finder#{format_ext(nf)}?token=#{nf.token}",
        input_url: "", file: nf.params[:source][:file], status: 303,
        engines: engines(nf.params[:engine]), unique: nf.params[:unique],
        verbatim: nf.params[:verbatim] }
    end

    def add_result(nf)
      names = nf.result[:names]
      unique_names = names.map { |n| n[:scientificName] }.uniq
      res = { status: nf.status_code, updated_at: Time.now,
              total: unique_names.count}
      res[:names] = nf.params[:unique] ? unique_names : names
      res[:content] = nf.text.text_norm if nf.params[:return_content]
      res[:resolved_names] = nf.result[:resolver] if nf.result[:resolver]
      res[:execution_time] = execution_time(nf)
      res
    end

    private

    def format_ext(nf)
      format = Sinatra::Formatter.new(nf).format
      format == :html ? "" : ".#{format}"
    end

    def execution_time(nf)
      tl = nf.result[:timeline]
      res = {
        text_extraction_duration: tl[:text_extraction] - tl[:start],
        find_names_duration: tl[:name_finding] - tl[:text_extraction],
        total_duration: tl[:stop] - tl[:start] }
      if nf.result[:resolver]
        res[:resole_names_duration] = tl[:stop] - tl[:name_finding]
      end
      res
    end

    def engines(num)
      case num
      when 0
        ENGINES
      when 1
        ENGINES[0]
      when 2
        ENGINES[1]
      end
    end
  end
end

