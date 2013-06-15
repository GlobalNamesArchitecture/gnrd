class AddApiKey < ActiveRecord::Migration
  def change
    add_column :name_finders, :api_key, :string
  end
end
