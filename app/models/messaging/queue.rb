module Models
  module Messaging
    class Queue < ::ApplicationRecord
      self.table_name = 'messaging_queues'

      validates :lock_version, presence: true, numericality: { only_integer: true }
      validates :name, presence: true, uniqueness: true

      has_many :messages, -> { order(created_at: :asc) }
    end
  end
end
