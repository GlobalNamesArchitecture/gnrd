class NameFinderNuker < ActiveRecord::Base

  @queue = :name_finder_nuker
  
  def self.perform(name_finder_id)
    nf = NameFinder.find(name_finder_id)
    if nf.input != nil
      nf.destroy
    end
  end

end