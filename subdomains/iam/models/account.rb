module IAM
  module Models
    class Account < ::ApplicationRecord
      self.table_name = 'iam_accounts'

      validates :lock_version, presence: true, numericality: { only_integer: true }

      has_many :user_accounts
      has_many :users, through: :user_accounts

      has_many :events, -> { order(created_at: :asc) }, as: :messageable, class_name: '::Models::Messaging::Event'
      has_many :commands, -> { order(created_at: :asc) }, as: :messageable, class_name: '::Models::Messaging::Command'
      has_many :messages, -> { order(created_at: :asc) }, as: :messageable, class_name: '::Models::Messaging::Message'
    end
  end
end
