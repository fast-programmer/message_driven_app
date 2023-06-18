class CreateMessagingErrors < ActiveRecord::Migration[6.0]
  def change
    create_table :messaging_errors do |t|
      t.integer :attempt, null: false

      t.text :class_name, null: false
      t.text :message_text, null: false
      t.text :backtrace, array: true

      t.references :message, null: false, unique: true, foreign_key: { to_table: :messaging_messages }

      t.timestamps
    end

    add_index :messaging_errors, [:message_id, :attempt], unique: true
  end
end
