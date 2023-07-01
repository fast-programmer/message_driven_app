module Models
  module Messaging
    class Message < ::ApplicationRecord
      self.table_name = 'messaging_messages'

      STATUS = {
        unhandled: 'unhandled',
        handling: 'handling',
        handled: 'handled',
        failed: 'failed'
      }.freeze

      attribute :status, :text, default: STATUS[:unhandled]
      attribute :attempts_count, :integer, default: 0
      attribute :attempts_max, :integer, default: 1

      belongs_to :queue, foreign_key: 'queue_id', class_name: '::Models::Messaging::Queue'
      belongs_to :account
      belongs_to :user
      belongs_to :messageable, polymorphic: true

      has_many :attempts, class_name: '::Models::Messaging::Message::Attempt', dependent: :destroy

      class Attempt < ApplicationRecord
        self.table_name = 'messaging_message_attempts'

        validates :was_successful, inclusion: { in: [true, false] }

        validates :error_class_name, :error_message, :error_backtrace, presence: true, unless: :was_successful?
        validates :error_class_name, :error_message, :error_backtrace, absence: true, if: :was_successful?

        belongs_to :message, foreign_key: 'message_id', class_name: '::Models::Messaging::Message'
      end

      validates :user_id, presence: true
      validates :type, presence: true
      validates :messageable_type, presence: true
      validates :messageable_id, presence: true
      validates :name, presence: true
      validates :status, presence: true

      validates :attempts_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :attempts_max, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

      validate :validate_attempts_count_not_greater_than_attempts_max
      def validate_attempts_count_not_greater_than_attempts_max
        if attempts_count > attempts_max
          errors.add(:attempts_count, 'cannot be greater than attempts_max')
        end
      end

      after_initialize :set_default_queue, if: :new_record?

      def set_default_queue
        self.queue ||= Queue.default
      end

      before_validation :set_account_id

      def set_account_id
        self.account_id ||= messageable.account_id if messageable.respond_to?(:account_id)
      end

      def body=(body)
        self.body_class_name = body.class.name
        self.body_json = body.class.encode(new_body)
      end

      def body
        body_class_name.constantize.decode(body_json)
      end
    end
  end
end
