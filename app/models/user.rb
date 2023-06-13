module Models
  class User < ::ApplicationRecord
    validates :email, presence: true, uniqueness: true

    has_many :events, as: :messageable
    has_many :commands, as: :messageable
    has_many :messages, as: :messageable
  end
end
