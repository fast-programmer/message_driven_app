class CreateMessagingErrors < ActiveRecord::Migration[6.0]
  def change
    create_table :messaging_errors do |t|
      t.text :class_name, null: false
      t.text :message_text, null: false
      t.text :backtrace, array: true

      t.references :message, null: false, unique: true, foreign_key: { to_table: :messaging_messages }

      t.timestamps
    end
  end
end
