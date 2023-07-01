class CreateMessagingMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messaging_messages do |t|
      t.bigint :account_id, null: false
      t.bigint :user_id, null: false

      t.bigint :queue_id, null: false

      t.text :status, null: false

      t.column :queue_until, 'timestamptz'

      t.integer :attempts_count, null: false
      t.integer :attempts_max, null: false

      t.text :type, null: false
      t.text :body_class_name, null: false
      t.jsonb :body_json, null: false

      t.text :messageable_type, null: false
      t.bigint :messageable_id, null: false

      t.column :created_at, 'timestamptz', null: false
      t.column :updated_at, 'timestamptz', null: false
    end

    add_foreign_key :messaging_messages, :iam_accounts, column: :account_id
    add_foreign_key :messaging_messages, :iam_users, column: :user_id

    add_foreign_key :messaging_messages, :messaging_queues, column: :queue_id

    add_index :messaging_messages, :type
    add_index :messaging_messages, :status
    add_index :messaging_messages, [:status, :created_at]
    add_index :messaging_messages, [:messageable_type, :messageable_id]
  end
end
