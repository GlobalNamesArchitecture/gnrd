class CreateNameFinder < ActiveRecord::Migration
  def change
    create_table :name_finders do |t|
      t.string  :token
      t.text    :input
      t.string  :input_url
      t.string  :file_path
      t.string  :file_name
      t.string  :file_format
      t.text    :output
      t.string  :url
      t.integer :engine, :default => 0
      t.boolean :unique
      t.string  :format
      t.string  :document_sha
      t.timestamps
    end
    add_index :name_finders, :token, :unique => true
    execute "alter table name_finders modify column input longtext"
    execute "alter table name_finders modify column output mediumtext"
  end
end
