class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.integer :lock_version, null: false, default: 0

      t.text :email, null: false

      t.timestamps
    end
  end
end
