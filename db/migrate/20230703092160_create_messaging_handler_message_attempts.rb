class CreateMessagingHandlerMessageAttempts < ActiveRecord::Migration[6.0]
  def change
    create_table :messaging_handler_message_attempts do |t|
      t.references :handler_message, null: false, foreign_key: { to_table: :messaging_handler_messages }
      t.integer :index, null: false

      t.column :started_at, 'timestamptz', null: false
      t.column :ended_at, 'timestamptz', null: false

      t.boolean :successful, null: false

      t.jsonb :return_value

      t.text :error_class_name
      t.text :error_message
      t.column :error_backtrace, :text, array: true
    end
  end
end
