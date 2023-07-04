module Messaging
  module Models
    class Message < ApplicationRecord
      self.table_name = 'messaging_messages'

      attribute :priority, :integer, default: 0
      attribute :attempts_max, :integer, default: 1

      belongs_to :queue, foreign_key: 'queue_id', class_name: '::Messaging::Models::Queue'
      belongs_to :account
      belongs_to :user
      belongs_to :messageable, polymorphic: true

      has_many :handler_messages, class_name: '::Messaging::Models::HandlerMessage'
      has_many :handlers, through: :handler_messages

      validates :account_id, presence: true
      validates :user_id, presence: true
      validates :type, presence: true

      validates :attempts_max, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

      validates :body_class_name, presence: true
      validates :body_json, presence: true, unless: -> { body_json == {} }

      validates :messageable_type, presence: true
      validates :messageable_id, presence: true

      after_initialize :set_default_queue, if: :new_record?

      def set_default_queue
        self.queue ||= Queue.default
      end

      before_validation :set_account_id
      def set_account_id
        self.account_id ||= messageable.account_id if messageable.respond_to?(:account_id)
      end

      after_create :create_handler_messages

      def create_handler_messages
        Models::Handler.where(enabled: true).find_each do |handler|
          if handler.handles?(message: self)
            handler_messages.create!(
              handler: handler,
              status: delayed_until.nil? ? Models::HandlerMessage::STATUS[:unhandled] : Models::HandlerMessage::STATUS[:delayed],
              delayed_until: delayed_until,
              priority: priority || 0,
              attempts_count: 0,
              attempts_max: attempts_max || 1)
          end
        end
      end

      def body=(body)
        self.body_class_name = body.class.name
        self.body_json = JSON.parse(body.to_json)
      end

      def body
        body_class_name.constantize.decode_json(body_json.to_json)
      end
    end
  end
end
