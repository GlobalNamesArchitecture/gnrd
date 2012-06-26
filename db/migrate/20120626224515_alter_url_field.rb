class AlterUrlField < ActiveRecord::Migration
  def change
    rename_column :name_finders, :url, :token_url
  end
end
