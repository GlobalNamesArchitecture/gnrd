class AddResolverFields < ActiveRecord::Migration
  def change
    add_column :name_finders, :preferred_data_sources, :string
    add_column :name_finders, :best_match_only, :boolean
  end
end
