class CreateMessagingRetries < ActiveRecord::Migration[6.0]
  def change
    create_table :messaging_retries do |t|
      t.integer :attempt, null: false

      t.references :message, null: false, unique: true, foreign_key: { to_table: :messaging_messages }

      t.timestamps
    end

    add_index :messaging_retries, [:message_id, :attempt], unique: true
  end
end
