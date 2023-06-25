class CreateMessagingQueues < ActiveRecord::Migration[6.0]
  def change
    create_table :messaging_queues do |t|
      t.integer :lock_version, null: false, default: 0
      t.text :name, null: false
    end

    add_index :messaging_queues, :name, unique: true
  end
end
