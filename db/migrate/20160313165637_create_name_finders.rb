class CreateNameFinders < ActiveRecord::Migration
  def change
    create_table :name_finders do |t|
      t.string   :token
      t.integer  :status_code
      t.string   :err_msg
      t.string   :redirect_path
      t.jsonb    :params
      t.jsonb    :text
      t.jsonb    :result
      t.jsonb    :errs
      t.jsonb    :output

      t.timestamps null: false
    end
  end
end
