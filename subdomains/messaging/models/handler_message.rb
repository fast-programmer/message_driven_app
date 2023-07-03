module Messaging
  module Models
    class HandlerMessage < ApplicationRecord
      self.table_name = 'messaging_handler_messages'

      STATUS = {
        unhandled: 'unhandled',
        handling: 'handling',
        handled: 'handled',
        failed: 'failed'
      }.freeze

      attribute :status, :text, default: STATUS[:unhandled]

      attribute :priority, :integer, default: 0
      attribute :attempts_count, :integer, default: 0
      attribute :attempts_max, :integer, default: 1

      class Attempt < ApplicationRecord
        self.table_name = 'messaging_handler_message_attempts'

        validates :successful, inclusion: { in: [true, false] }

        validates :error_class_name, :error_message, :error_backtrace, presence: true, unless: :successful?
        validates :error_class_name, :error_message, :error_backtrace, absence: true, if: :successful?

        belongs_to :message, foreign_key: 'message_id', class_name: '::Messaging::Models::Message'
      end

      belongs_to :message, foreign_key: 'message_id', class_name: '::Messaging::Models::Message'
      belongs_to :handler, foreign_key: 'handler_id', class_name: '::Messaging::Models::Handler'
      has_many :attempts, class_name: '::Messaging::Models::HandlerMessage::Attempt', dependent: :destroy

      validates :message_id, presence: true
      validates :handler_id, presence: true

      validates :status, presence: true

      validates :priority, numericality: { greater_than_or_equal_to: 0 }
      validates :attempts_count, presence: true, numericality: {
                  only_integer: true, greater_than_or_equal_to: 0 }
      validates :attempts_max, presence: true, numericality: {
                  only_integer: true, greater_than_or_equal_to: 1 }

      validate :validate_attempts_count_not_greater_than_attempts_max
      def validate_attempts_count_not_greater_than_attempts_max
        if attempts_count > attempts_max
          errors.add(:attempts_count, 'cannot be greater than attempts_max')
        end
      end

      def queue_until=(time)
        self[:queue_until] = time.nil? ? nil : time.utc
      end

      def queue_until
        self[:queue_until]&.in_time_zone
      end
    end
  end
end
