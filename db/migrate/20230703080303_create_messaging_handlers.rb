class CreateMessagingHandlers < ActiveRecord::Migration[6.0]
  def change
    create_table :messaging_handlers do |t|
      t.bigint :queue_id, null: false
      t.text :slug, null: false
      t.text :name, null: false

      t.text :class_name, null: false
      t.text :method_name, null: false

      t.boolean :enabled, null: false

      t.column :created_at, 'timestamptz', null: false
      t.column :updated_at, 'timestamptz', null: false
    end

    add_index :messaging_handlers, [:queue_id, :slug], unique: true
    add_foreign_key :messaging_handlers, :messaging_queues, column: :queue_id
  end
end
