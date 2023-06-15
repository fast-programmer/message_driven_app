require_relative '../messages/user'

module IAM
  module User
    module_function

    class Error < StandardError; end
    class NotFound < StandardError; end

    def create(email:, created_at: Time.now.utc)
      ActiveRecord::Base.transaction do
        user = Models::User.create!(email: email)
        user_created_event = Messages::User.created(email: email)

        user.events.create!(
          user_id: user.id,
          name: user_created_event.name,
          body: user_created_event.body
        )

        user.readonly!
        user.freeze

        user
      end
    rescue ActiveRecord::RecordInvalid => e
      raise Error.new(e.record.errors.full_messages.to_sentence)
    rescue ActiveRecord::RecordNotUnique => e
      raise Error.new("Database error: #{e.message}")
    end

    def sync_async(user_id:, id:)
      user = Models::User.find(id)
      sync_user_command = Messages::User.sync

      user.commands.create!(
        user_id: user.id,
        name: sync_user_command.name,
        body: sync_user_command.body
      )

      user.readonly!
      user.freeze

      user
    rescue ActiveRecord::RecordNotFound => e
      raise NotFound.new("Not found: #{e.message}")
    rescue ActiveRecord::RecordInvalid => e
      raise Error.new(e.record.errors.full_messages.to_sentence)
    end

    def sync(user_id:, id:, created_at: Time.now.utc)
      user = Models::User.find(id)
      synced_user_event = Messages::User.synced

      user.events.create!(
        user_id: user_id,
        name: synced_user_event.name,
        body: synced_user_event.body
      )

      user.readonly!
      user.freeze

      user
    rescue ActiveRecord::RecordNotFound => e
      raise NotFound.new("Not found: #{e.message}")
    rescue ActiveRecord::RecordInvalid => e
      raise Error.new(e.record.errors.full_messages.to_sentence)
    end
  end
end
