class CreateNameFinders < ActiveRecord::Migration
  def change
    create_table :name_finders do |t|
      t.string :token
      t.jsonb :params
      t.jsonb :input
      t.jsonb :output
    end
  end
end
