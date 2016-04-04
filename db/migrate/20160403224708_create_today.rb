class CreateToday < ActiveRecord::Migration
  def change
    create_table :today do |t|
      t.string   :today
    end
  end
end
