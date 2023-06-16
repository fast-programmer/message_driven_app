class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.integer :lock_version, null: false, default: 0
      t.text :name, null: false
      t.text :slug, null: false
      t.references :owner, null: false, foreign_key: { to_table: :users }
    end
  end
end
