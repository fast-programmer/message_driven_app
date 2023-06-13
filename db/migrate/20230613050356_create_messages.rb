class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.text :name, null: false
      t.text :status, null: false
      t.jsonb :body
      t.timestamps
    end

    add_index :messages, [:status, :created_at]
  end
end

# TODO: add account_id, user_id, messageable_type, messageable_id
