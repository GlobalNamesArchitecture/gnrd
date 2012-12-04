class AllDataSources < ActiveRecord::Migration
  def change
    add_column :name_finders, :all_data_sources, :boolean
  end
end
