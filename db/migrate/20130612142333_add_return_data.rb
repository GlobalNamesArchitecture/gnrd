class AddReturnData < ActiveRecord::Migration
  def change
    add_column :name_finders, :return_content, :boolean
  end
end
