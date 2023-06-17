module Models
  class Message < ::ApplicationRecord
    class Body
      def initialize(hash)
        @hash = hash
      end

      def method_missing(name, *args, &block)
        if name[-1] == "="
          @hash[name[0...-1]] = args[0]
        else
          @hash[name.to_s]
        end
      end

      def to_h
        @hash
      end
    end

    validates :user_id, presence: true
    validates :type, presence: true
    validates :messageable_type, presence: true
    validates :messageable_id, presence: true
    validates :name, presence: true
    validates :status, presence: true

    validates :retry_count, :retry_limit, presence: true
    validates :retry_count, :retry_limit, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validate :retry_count_not_greater_than_retry_limit

    def retry_count_not_greater_than_retry_limit
      if retry_count.present? && retry_limit.present? && retry_count > retry_limit
        errors.add(:retry_count, "can't be greater than retry limit")
      end
    end

    belongs_to :queue
    belongs_to :account
    belongs_to :user
    belongs_to :messageable, polymorphic: true

    STATUS = {
      unhandled: 'unhandled',
      handling: 'handling',
      handled: 'handled',
      failed: 'failed'
    }.freeze

    attribute :status, :text, default: STATUS[:unhandled]

    def body
      Body.new(super)
    end

    def body=(new_body)
      if new_body.is_a?(Body)
        super(new_body.to_h)
      else
        super(new_body)
      end
    end
  end
end
