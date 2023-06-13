class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.text :type, null: false
      t.text :messageable_type, null: false
      t.bigint :messageable_id, null: false
      t.text :name, null: false
      t.text :status, null: false
      t.jsonb :body
      t.timestamps
    end

    add_index :messages, :type
    add_index :messages, :status
    add_index :messages, [:status, :created_at]
    add_index :messages, [:messageable_type, :messageable_id]
  end
end

# TODO: add user_id
