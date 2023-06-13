module Models
  class Message < ::ApplicationRecord
    belongs_to :messageable, polymorphic: true

    STATUS = {
      unpublished: 'unpublished',
      publishing: 'publishing',
      published: 'published',
      failed: 'failed'
    }.freeze

    attribute :status, :text, default: STATUS[:unpublished]
  end
end
