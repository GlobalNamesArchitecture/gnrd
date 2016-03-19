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

  def self.enqueue(resource)
    Resque::Job.create(self, resource.id)
  end

  def self.perform(name_finder_id)
    nf = NameFinder.find(name_finder_id)
    nf.name_find
  end

  def prepare
  end

  def error?
    false
  end

  before_create do
    self.token = NameFinder.token
    self.params = Params.new(params).normalize
  end
end
