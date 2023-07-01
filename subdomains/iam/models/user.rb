module IAM
  module Models
    class User < ::ApplicationRecord
      self.table_name = 'iam_users'

      validates :lock_version, presence: true, numericality: { only_integer: true }
      validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

      has_many :user_accounts
      has_many :accounts, through: :user_accounts

      has_many :events, -> { order(created_at: :asc) }, as: :messageable, class_name: '::Models::Messaging::Event'
      has_many :commands, -> { order(created_at: :asc) }, as: :messageable, class_name: '::Models::Messaging::Command'
      has_many :messages, -> { order(created_at: :asc) }, as: :messageable, class_name: '::Models::Messaging::Message'
    end
  end
end
