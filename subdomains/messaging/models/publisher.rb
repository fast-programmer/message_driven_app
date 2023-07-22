module Messaging
  module Models
    class Publisher < ApplicationRecord
      self.table_name = 'messaging_publishers'

      attribute :is_enabled, :boolean, default: true
      validates :is_enabled, inclusion: { in: [true, false] }

      attribute :lock_version, :integer, default: 0
      validates :lock_version, presence: true,
        numericality: { only_integer: true, greater_than_or_equal_to: 0 }

      validates :handler_class_name, :handler_method_name, presence: true

      validates :created_at, :updated_at, presence: true
    end
  end
end
