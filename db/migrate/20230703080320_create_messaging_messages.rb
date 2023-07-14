class CreateMessagingMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messaging_messages do |t|
      t.bigint :account_id, null: false
      t.bigint :user_id, null: false

      t.text :type, null: false

      t.text :body_class_name, null: false
      t.jsonb :body_json, null: false

      t.text :messageable_type, null: false
      t.bigint :messageable_id, null: false

      t.column :created_at, 'timestamptz', null: false
      t.column :updated_at, 'timestamptz', null: false
    end
  end
end
