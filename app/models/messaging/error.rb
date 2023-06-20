module Models
  module Messaging
    class Error < ::ApplicationRecord
      self.table_name = 'messaging_errors'

      belongs_to :message, foreign_key: 'message_id', class_name: '::Models::Messaging::Message'
    end
  end
end
