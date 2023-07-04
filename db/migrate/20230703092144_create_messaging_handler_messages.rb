class CreateMessagingHandlerMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messaging_handler_messages do |t|
      t.bigint :message_id, null: false
      t.bigint :handler_id, null: false

      t.text :status, null: false

      t.bigint :priority, null: false
      t.column :delayed_until, 'timestamptz'
      t.integer :attempts_count, null: false
      t.integer :attempts_max, null: false

      t.column :created_at, 'timestamptz', null: false
      t.column :updated_at, 'timestamptz', null: false
    end

    add_foreign_key :messaging_handler_messages, :messaging_messages, column: :message_id
    add_foreign_key :messaging_handler_messages, :messaging_handlers, column: :handler_id

    add_index :messaging_handler_messages, [:message_id, :handler_id], unique: true

    add_index :messaging_handler_messages, :status
  end
end
