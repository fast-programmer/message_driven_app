module Messaging
  module Models
    class Handler < ApplicationRecord
      self.table_name = 'messaging_handlers'

      validates :queue_id, presence: true

      validates :name, presence: true, uniqueness: true
      validates :slug, presence: true, uniqueness: { scope: :queue_id }

      validates :class_name, presence: true

      validates :enabled, inclusion: { in: [true, false] }

      belongs_to :queue, class_name: '::Messaging::Models::Queue', foreign_key: :queue_id

      has_many :handler_messages, class_name: '::Messaging::Models::HandlerMessage'
      has_many :messages, through: :handler_messages

      def handles?(message:)
        self.class_name.constantize.handles?(message: message)
      end
    end
  end
end
