# Gathers parameters and input from users, calls name finding utitilites and
# saves their output.
class NameFinder < ActiveRecord::Base
  serialize :params, HashSerializer
  serialize :errs, HashSerializer
  serialize :output, HashSerializer

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

  def errors?
    self.errs = Errors.new(self).validate if errs.is_a?(Hash)
    if errs.empty?
      false
    else
      save_error
    end
  end

  before_create do
    self.token = NameFinder.token
    self.params = Params.new(params).normalize
  end

  private

  def save_error
    self.status_code = errs.first[:status_code]
    self.output = { status: errs.first[:status_code],
                    message: errs.first[:message] }
    save!
    true
  end
end
