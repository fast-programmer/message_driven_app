module Messaging
  module Models
    class Queue < ::ApplicationRecord
      self.table_name = 'messaging_queues'

      DEFAULT_NAME = 'default'
      DEFAULT_SLUG = DEFAULT_NAME

      def self.default_id
        default.id
      end

      def self.default
        find_or_create_by!(name: DEFAULT_NAME, slug: DEFAULT_SLUG)
      end

      validates :lock_version, presence: true, numericality: { only_integer: true }
      validates :name, presence: true, uniqueness: true

      has_many :messages, -> { order(created_at: :asc) }

      has_many :handlers, class_name: '::Messaging::Models::Handler', foreign_key: :queue_id
    end
  end
end
