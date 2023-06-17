module Models
  class Queue < ::ApplicationRecord
    validates :lock_version, presence: true, numericality: { only_integer: true }
    validates :name, presence: true, uniqueness: true

    has_many :messages, -> { order(created_at: :asc) }
  end
end
