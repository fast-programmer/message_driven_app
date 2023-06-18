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

      belongs_to :queue, foreign_key: 'queue_id', class_name: '::Models::Messaging::Queue'
      belongs_to :account
      belongs_to :user
      belongs_to :messageable, polymorphic: true

      has_many :messaging_errors, foreign_key: 'message_id', class_name: "::Models::Messaging::Error", dependent: :destroy
      has_many :retries, class_name: '::Models::Messaging::Retry', foreign_key: 'message_id'

      validates :user_id, presence: true
      validates :type, presence: true
      validates :messageable_type, presence: true
      validates :messageable_id, presence: true
      validates :name, presence: true
      validates :status, presence: true
      validates :retry_limit, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

      # validate :validate_retry_count_not_greater_than_retry_limit
      # def validate_retry_count_not_greater_than_retry_limit
      #   if retries.maximum(:attempt) > retry_limit
      #     errors.add(:retries, "can't be greater than retry limit")
      #   end
      # end

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
