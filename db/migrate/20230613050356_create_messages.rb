class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
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
      t.text :backoff_strategy

      t.column :created_at, 'timestamptz', null: false
      t.column :updated_at, 'timestamptz', null: false

      t.text :error_class_name
      t.text :error_message
      t.text :error_backtrace, array: true
    end

    add_foreign_key :messages, :accounts, column: :account_id
    add_foreign_key :messages, :users, column: :user_id

    add_index :messages, :type
    add_index :messages, :status
    add_index :messages, [:status, :created_at]
    add_index :messages, [:messageable_type, :messageable_id]
  end
end
