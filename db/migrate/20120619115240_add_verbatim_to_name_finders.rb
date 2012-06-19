class AddVerbatimToNameFinders < ActiveRecord::Migration
  def change
    add_column :name_finders, :verbatim, :boolean, :default => 1
  end
end
