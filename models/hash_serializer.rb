# Symbolizes jsonb
class HashSerializer
  def self.symbolize_keys(obj)
    case obj
    when Array then obj.map { |v| symbolize_keys(v) }
    when Hash
      obj.each_with_object({}) do |(k, v), o|
        v = v.path if k.to_s == "tempfile" && v.is_a?(Tempfile)
        o[k] = symbolize_keys(v)
      end.symbolize_keys
    else
      obj
    end
  end

  def self.dump(hash)
    hash.to_json
  end

  def self.load(hash)
    symbolize_keys(hash || {})
  end
end
