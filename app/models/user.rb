module Models
  class User < ::ApplicationRecord
    validates :lock_version, presence: true, numericality: { only_integer: true }
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

    has_many :user_accounts
    has_many :accounts, through: :user_accounts

    has_many :events, -> { order(created_at: :asc) }, as: :messageable, class_name: '::Models::Event'
    has_many :commands, -> { order(created_at: :asc) }, as: :messageable, class_name: '::Models::Command'
    has_many :messages, -> { order(created_at: :asc) }, as: :messageable, class_name: '::Models::Message'
  end
end
