module IAM
  module User
    module_function

    class Error < StandardError; end

    def create(email:, created_at: Time.now.utc)
      user = nil

      ActiveRecord::Base.transaction do
        user = Models::User.new(email: email, created_at: created_at)
        raise Error.new(user.errors.full_messages.to_sentence) unless user.save

        event = user.events.build(user_id: user.id, name: 'IAM::User.created', created_at: created_at)
        raise Error.new(event.errors.full_messages.to_sentence) unless event.save
      end

      user.readonly!
      user.freeze

      user
    rescue ActiveRecord::RecordNotUnique => e
      raise Error.new("Database error: #{e.message}")
    end
  end
end
