module Models
  class Message < ::ApplicationRecord
    validates :type, presence: true
    validates :messageable_type, presence: true
    validates :messageable_id, presence: true
    validates :user_id, presence: true
    validates :name, presence: true
    validates :status, presence: true
    validates :body, presence: true

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
