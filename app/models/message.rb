class Message < ApplicationRecord
  STATUS = {
    unpublished: 'unpublished',
    publishing: 'publishing',
    published: 'published',
    failed: 'failed'
  }.freeze

  attribute :status, :text, default: STATUS[:unpublished]
end
