class CreateIamUserAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :iam_user_accounts do |t|
      t.integer :lock_version, null: false, default: 0

      t.references :user, null: false, foreign_key: { to_table: :iam_users }
      t.references :account, null: false, foreign_key: { to_table: :iam_accounts }
    end
  end
end
