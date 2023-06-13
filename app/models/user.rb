module Models
  class User < ::ApplicationRecord
    validates :lock_version, presence: true, numericality: { only_integer: true }
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

    has_many :events, as: :messageable
    has_many :commands, as: :messageable
    has_many :messages, as: :messageable
  end
end
