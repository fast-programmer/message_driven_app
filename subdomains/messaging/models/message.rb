module Messaging
  module Models
    class Message < ApplicationRecord
      self.table_name = 'messaging_messages'

      attr_accessor :skip_publishing

      def skip_publishing?
        @skip_publishing.nil? ? false : @skip_publishing
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

      after_create :publish, unless: :skip_publishing?

      def publish
        Models::Publisher.where(enabled: true).map do |publisher|
          jobs.create!(handler: publisher.handler)
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
