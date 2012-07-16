class AddExpandToNameFinders < ActiveRecord::Migration
  def change
    add_column :name_finders, :expand, :boolean, :default => 1
  end
end
