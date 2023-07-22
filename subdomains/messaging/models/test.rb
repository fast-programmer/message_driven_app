module Messaging
  module Models
    class Test < ApplicationRecord
      self.table_name = 'messaging_tests'

      attribute :lock_version, :integer, default: 0
      validates :lock_version, presence: true, numericality: { only_integer: true }

      has_many :messages, -> { order(created_at: :asc) }, as: :messageable, class_name: '::Messaging::Models::Message'
      has_many :events, -> { order(created_at: :asc) }, as: :messageable, class_name: '::Messaging::Models::Event'
      has_many :commands, -> { order(created_at: :asc) }, as: :messageable, class_name: '::Messaging::Models::Command'
    end
  end
end
