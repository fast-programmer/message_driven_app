class CreateMessagingMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messaging_messages do |t|
      t.bigint :queue_id, null: false
      t.bigint :account_id
      t.bigint :user_id, null: false
      t.text :name, null: false
      t.text :type, null: false
      t.jsonb :body
      t.text :status, null: false
      t.text :messageable_type, null: false
      t.bigint :messageable_id, null: false

      t.column :queued_until, 'timestamptz'

      t.integer :retry_count, null: false, default: 0
      t.integer :retry_limit, null: false, default: 0

      t.column :created_at, 'timestamptz', null: false
      t.column :updated_at, 'timestamptz', null: false

      t.text :error_class_name
      t.text :error_message
      t.text :error_backtrace, array: true
    end

    add_foreign_key :messaging_messages, :messaging_queues, column: :queue_id
    add_foreign_key :messaging_messages, :accounts, column: :account_id
    add_foreign_key :messaging_messages, :users, column: :user_id

    add_index :messaging_messages, :type
    add_index :messaging_messages, :status
    add_index :messaging_messages, [:status, :created_at]
    add_index :messaging_messages, [:messageable_type, :messageable_id]
  end
end
