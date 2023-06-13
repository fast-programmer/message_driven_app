module IAM
  module Models
    class User < ::ApplicationRecord
      validates :lock_version, presence: true, numericality: { only_integer: true }
      validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

      has_many :events, as: :messageable, class_name: '::Models::Event'
      has_many :commands, as: :messageable, class_name: '::Models::Command'
      has_many :messages, as: :messageable, class_name: '::Models::Message'
    end
  end
end
