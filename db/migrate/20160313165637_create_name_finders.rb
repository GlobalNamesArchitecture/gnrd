class CreateNameFinders < ActiveRecord::Migration[5.2]
  def change
    create_table :name_finders do |t|
      t.string   :token
      t.jsonb    :params
      t.integer  :current_state, default: 0

      t.jsonb    :result
      t.jsonb    :output
      t.jsonb    :errs, default: []

      t.timestamps null: false
    end
  end
end
