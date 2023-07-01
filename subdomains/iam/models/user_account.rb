module Models
  module IAM
    class UserAccount < ::ApplicationRecord
      self.table_name = 'iam_user_accounts'

      validates :lock_version, presence: true, numericality: { only_integer: true }

      belongs_to :user
      belongs_to :account
    end
  end
end
