# Symbolizes jsonb
class HashSerializer
  def self.dump(hash)
    hash.to_json
  end

  def self.load(hash)
    Gnrd.symbolize_keys(hash || {})
  end
end

# Gathers parameters and input from users, calls name finding utitilites and
# saves their output.
class NameFinder < ActiveRecord::Base
  serialize :params, HashSerializer

  def self.token
    loop do
      t = rand(1e18..9e18).to_i.to_s(32)[0..9]
      return t unless find_by_token(t)
    end
  end

  before_create do
    self.token = NameFinder.token
    self.params = Gnrd::App::Params.new(params).normalize
  end
end
