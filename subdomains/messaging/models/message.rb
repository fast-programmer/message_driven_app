module Messaging
  module Models
    class Message < ApplicationRecord
      self.table_name = 'messaging_messages'

      attr_accessor :skip_create_jobs

      def skip_create_jobs?
        @skip_create_jobs.nil? ? false : @skip_create_jobs
      end

      belongs_to :account
      belongs_to :user
      belongs_to :messageable, polymorphic: true

      has_many :jobs, class_name: '::Messaging::Models::Job'

      validates :account_id, presence: true
      validates :user_id, presence: true
      validates :type, presence: true

      validates :body_class_name, presence: true
      validates :body_json, presence: true, unless: -> { body_json == {} }

      validates :messageable_type, presence: true
      validates :messageable_id, presence: true

      before_validation :set_account_id, if: -> { account_id.nil? }
      def set_account_id
        self.account_id = messageable.account_id
      end

      before_validation :set_user_id, if: -> { user_id.nil? }
      def set_user_id
        self.user_id = messageable.user_id
      end

      after_create :create_jobs, unless: :skip_create_jobs?

      def create_jobs
        Models::Handler.where(enabled: true).find_each do |handler|
          klass = handler.class_name.constantize

          if klass.respond_to?(:handles?) && klass.handles?(message: self)
            scheduled_for = (klass.respond_to?(:scheduled_for) && klass.scheduled_for) || nil
            priority = (klass.respond_to?(:priority) && klass.priority) || 0
            attempts_max = (klass.respond_to?(:attempts_max) && klass.attempts_max) || 1

            jobs.create!(
              queue_id: handler.queue_id,
              handler: handler.class_name.constantize,
              status: scheduled_for ? Models::Job::STATUS[:scheduled] : Models::Job::STATUS[:queued],
              priority: priority,
              attempts_max: attempts_max)
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
