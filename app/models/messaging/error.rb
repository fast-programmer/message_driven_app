module Models
  module Messaging
    class Error < ::ApplicationRecord
      self.table_name = 'messaging_errors'

      belongs_to :message, foreign_key: 'message_id', class_name: '::Models::Messaging::Message'

      validates :attempt, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
    end
  end
end
