class AddResolution < ActiveRecord::Migration
  def change
    add_column :name_finders, :data_source_ids, :text
  end
end
