class CreateMessagingJobs < ActiveRecord::Migration[6.0]
  def change
    create_table :messaging_jobs do |t|
      t.bigint :queue_id, null: false
      t.bigint :message_id, null: false

      t.text :handler_class_name, null: false

      t.text :status, null: false

      t.bigint :priority, null: false
      t.column :scheduled_for, 'timestamptz'
      t.integer :attempts_count, null: false
      t.integer :attempts_max, null: false

      t.column :created_at, 'timestamptz', null: false
      t.column :updated_at, 'timestamptz', null: false
    end

    add_foreign_key :messaging_jobs, :messaging_queues, column: :queue_id
    add_foreign_key :messaging_jobs, :messaging_messages, column: :message_id

    add_index :messaging_jobs, :status
  end
end
