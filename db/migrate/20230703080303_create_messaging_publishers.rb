class CreateMessagingPublishers < ActiveRecord::Migration[6.0]
  def change
    create_table :messaging_publishers do |t|
      t.integer :lock_version, null: false

      t.boolean :is_enabled, null: false

      t.text :handler_class_name, null: false
      t.text :handler_method_name, null: false

      t.column :created_at, 'timestamptz', null: false
      t.column :updated_at, 'timestamptz', null: false
    end
  end
end
