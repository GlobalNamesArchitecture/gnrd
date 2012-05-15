class CreateNameFinder < ActiveRecord::Migration
  def change
    create_table :name_finders do |t|
      t.string  :token
      t.text    :input
      t.string  :url
      t.string  :file_path
      t.text    :output
      t.string  :engine
      t.boolean :unique
      t.string  :format
      t.string  :document_sha
      t.timestamps
    end
    add_index :name_finders, :token, :unique => true
  end
end
