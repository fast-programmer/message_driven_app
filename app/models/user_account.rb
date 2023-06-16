module Models
  class UserAccount < ::ApplicationRecord
    validates :lock_version, presence: true, numericality: { only_integer: true }

    belongs_to :user
    belongs_to :account
  end
end
