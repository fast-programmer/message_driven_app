module Models
  module Messaging
    class Message < ::ApplicationRecord
      self.table_name = 'messaging_messages'

      has_many :tries, class_name: '::Models::Messaging::Message::Try', dependent: :destroy

      class Try < ApplicationRecord
        self.table_name = 'messaging_message_tries'

        validates :was_successful, inclusion: { in: [true, false] }

        validates :error_class_name, :error_message, :error_backtrace, presence: true, unless: :was_successful?
        validates :error_class_name, :error_message, :error_backtrace, absence: true, if: :was_successful?

        belongs_to :message, foreign_key: 'message_id', class_name: '::Models::Messaging::Message'
      end

      STATUS = {
        unhandled: 'unhandled',
        handling: 'handling',
        handled: 'handled',
        failed: 'failed'
      }.freeze

      attribute :status, :text, default: STATUS[:unhandled]
      attribute :tries_count, :integer, default: 0
      attribute :tries_max, :integer, default: 1

      belongs_to :queue, foreign_key: 'queue_id', class_name: '::Models::Messaging::Queue'
      belongs_to :account
      belongs_to :user
      belongs_to :messageable, polymorphic: true

      validates :user_id, presence: true
      validates :type, presence: true
      validates :messageable_type, presence: true
      validates :messageable_id, presence: true
      validates :name, presence: true
      validates :status, presence: true

      validates :tries_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :tries_max, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

      validate :validate_tries_count_not_greater_than_tries_max
      def validate_tries_count_not_greater_than_tries_max
        if tries_count > tries_max
          errors.add(:tries_count, 'cannot be greater than tries_max')
        end
      end

      after_initialize :set_default_queue, if: :new_record?

      def set_default_queue
        self.queue ||= Queue.default
      end

      before_update :delete_error, if: -> { status_changed? && status_before_last_save == 'failed' && status != 'failed' }

      def delete_error
        error&.destroy
      end

      class Body
        def initialize(hash)
          @hash = hash
        end

        def method_missing(name, *args, &block)
          if name[-1] == "="
            @hash[name[0...-1]] = args[0]
          else
            @hash[name.to_s]
          end
        end

        def to_h
          @hash
        end
      end

      def body
        Body.new(super)
      end

      def body=(new_body)
        if new_body.is_a?(Body)
          super(new_body.to_h)
        else
          super(new_body)
        end
      end
    end
  end
end
