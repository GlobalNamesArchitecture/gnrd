# Symbolizes jsonb
class HashSerializer
  def self.dump(hash)
    hash.to_json
  end

  def self.load(hash)
    Gnrd.symbolize_keys(hash || {})
  end
end
