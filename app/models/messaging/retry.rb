module Models
  module Messaging
    class Retry < ::ApplicationRecord
      self.table_name = 'messaging_retries'

      belongs_to :message, foreign_key: 'message_id', class_name: '::Models::Messaging::Message'

      validates :attempt, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
    end
  end
end
