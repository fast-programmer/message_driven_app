class CreateUserAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :user_accounts do |t|
      t.integer :lock_version, null: false, default: 0

      t.references :user, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
    end
  end
end
