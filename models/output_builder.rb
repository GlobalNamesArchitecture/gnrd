# Creates final output for name-finding result
class OutputBuilder
  ENGINES = %w(TaxonFinder NetiNeti).freeze

  class << self
    def init(nf)
      { token_url: "/name_finder#{format(nf)}?token=#{nf.token}",
        input_url: nf.params[:source][:url],
        file: nf.params[:source][:file], status: 303,
        engines: engines(nf.params[:engine]), unique: nf.params[:unique],
        verbatim: nf.params[:verbatim] }
    end

    def add_result(nf)
      res = { names: prepare_names(nf) }
      res.merge!(status: nf.status_code, total: res[:names].count,
                 execution_time: execution_time(nf))
      res[:content] = nf.text.text_norm if nf.params[:return_content]
      res[:resolved_names] = nf.result[:resolver] if nf.result[:resolver]
      res
    end

    private

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
        ENGINES[0]
      when 2
        ENGINES[1]
      end
    end
  end
end
