class QueuePriority < ActiveRecord::Migration
  def change
    create_table :api_agents do |t|
      t.string :agent
      t.string :key
      t.string :priority
      t.timestamps
    end
    add_index :api_agents, :key, :unique => true
  end
end
