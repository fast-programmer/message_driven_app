module Messaging
  module Models
    class Job < ApplicationRecord
      self.table_name = 'messaging_jobs'

      STATUS = {
        scheduled: 'scheduled',
        rescheduled: 'rescheduled',
        queued: 'queued',
        processing: 'processing',
        processed: 'processed',
        failed: 'failed'
      }.freeze

      attribute :status, :text, default: STATUS[:queued]

      attribute :priority, :integer, default: 0
      attribute :attempts_count, :integer, default: 0
      attribute :attempts_max, :integer, default: 1

      def handler=(handler)
        handler_class_name, handler_method_name = handler.split('.')

        handler_class_name

        self.handler_class_name = handler_class_name
        self.handler_method_name = handler_method_name
      end

      def handler
        [handler_class_name, handler_method_name].join('.')
      end

      class Attempt < ApplicationRecord
        self.table_name = 'messaging_job_attempts'

        validates :successful, inclusion: { in: [true, false] }

        validates :error_class_name, :error_message, :error_backtrace, presence: true, unless: :successful?
        validates :error_class_name, :error_message, :error_backtrace, absence: true, if: :successful?

        belongs_to :message, foreign_key: 'message_id', class_name: '::Messaging::Models::Message'
      end

      belongs_to :queue, foreign_key: 'queue_id', class_name: '::Messaging::Models::Queue'
      belongs_to :message, foreign_key: 'message_id', class_name: '::Messaging::Models::Message'
      has_many :attempts, class_name: '::Messaging::Models::Job::Attempt', dependent: :destroy

      validates :queue_id, presence: true
      validates :message_id, presence: true

      validates :status, presence: true,
        inclusion: { in: STATUS.values, message: "%{value} is not a valid status" }

      validate :validate_process_at
      def validate_process_at
        if [STATUS[:scheduled], STATUS[:rescheduled]].include?(status) && process_at.nil?
          errors.add(:process_at, "must be present when status is #{status}")
        elsif ![STATUS[:scheduled], STATUS[:rescheduled]].include?(status) && process_at.present?
          errors.add(:process_at, "must be nil when status is not #{status}")
        end
      end

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

      after_initialize :set_default_queue, if: :new_record?

      def set_default_queue
        self.queue ||= Queue.default
      end
    end
  end
end
