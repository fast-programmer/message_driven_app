class CreateMessagingTests < ActiveRecord::Migration[6.0]
  def change
    create_table :messaging_tests do |t|
      t.integer :lock_version, null: false

      t.column :created_at, 'timestamptz', null: false
      t.column :updated_at, 'timestamptz', null: false
    end
  end
end
