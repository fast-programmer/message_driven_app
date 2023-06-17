class CreateQueues < ActiveRecord::Migration[6.0]
  def change
    create_table :queues do |t|
      t.integer :lock_version, null: false, default: 0
      t.text :name, null: false
    end

    add_index :queues, :name, unique: true
  end
end
