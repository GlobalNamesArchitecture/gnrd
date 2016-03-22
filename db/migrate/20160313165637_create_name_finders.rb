class CreateNameFinders < ActiveRecord::Migration
  def change
    create_table :name_finders do |t|
      t.string   :token
      t.integer  :current_state, default: 0
      t.integer  :status_code, default: 303
      t.jsonb    :result
      t.jsonb    :errs

      t.jsonb    :params
      t.jsonb    :output

      t.timestamps null: false
    end
  end
end
