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
    res
  end

  def update
    { format: normalize_format }
  end

  private

  def params_sources
    %i(url file text).each_with_object({}) do |p, obj|
      v =  params.delete(p) || (params[:find] && params[:find].delete(p))
      next if v.to_s.strip == ""
      v = normalize_file_source(v) if p == :file
      obj[p] = v
    end
  end

  def normalize_file_source(src)
    { filename: src[:filename], tempfile: src[:tempfile], type: src[:type] }
  end

  def params_boolean
    %i(unique return_content all_data_sources best_match_only)
      .each_with_object({}) do |p, obj|
      obj[p] = %w(1 true).include? params[p].to_s.strip
    end
  end

  def normalize_format
    fmt = params[:format] ? params[:format].strip : "html"
    %w(json xml html).include?(fmt) ? fmt : "html"
  end

  def detect_language?
    dt = params[:detect_language] ||
         (params[:find] && params[:find][:detect_language])
    return true if dt.nil?
    %w(0 false).include? dt.to_s.strip ? false : true
  end

  def params_data_sources
    %i(data_source_ids preferred_data_sources)
      .each_with_object({}) do |p, obj|
      obj[p] = params[p] ? normalize_data_source(params[p]) : []
    end
  end

  def normalize_data_source(value)
    v = value.is_a?(Array) ? value : value.split("|")
    v.uniq.compact.map(&:to_i).select { |i| i != 0 }
  end

  def normalize_engine
    engine = params[:engine].to_i
    (0..2).cover?(engine) ? engine : 0
  end
end
