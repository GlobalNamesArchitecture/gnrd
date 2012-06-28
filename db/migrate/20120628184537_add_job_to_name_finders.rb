class AddJobToNameFinders < ActiveRecord::Migration
  def change
    add_column :name_finders, :job, :integer, :default => 0
  end
end
