class CreateToday < ActiveRecord::Migration[5.2]
  def change
    create_table :today do |t|
      t.string   :today
    end
  end
end
