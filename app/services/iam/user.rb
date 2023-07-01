module IAM
  module User
    module_function

    class Error < StandardError; end
    class NotFound < Error; end

    def create(email:)
      user = nil
      event = nil

      ActiveRecord::Base.transaction do
        user = Models::IAM::User.create!(email: email)

        account = Models::IAM::Account.create!(
          name: "Account #{user.id}",
          slug: "account-#{user.id}",
          owner_id: user.id)

        Models::IAM::UserAccount.create!(user_id: user.id, account_id: account.id)

        event = user.events.create!(
          account_id: account.id,
          user_id: user.id,
          body: Messages::IAM::User::Created.new(
            email: user.email))
      end

      [user.tap(&:readonly!), event.tap(&:readonly!)]
    rescue ActiveRecord::RecordInvalid => e
      raise Error.new(e.record.errors.full_messages.to_sentence)
    rescue ActiveRecord::RecordNotUnique => e
      raise Error.new("Database error: #{e.message}")
    end

    def sync_async(account_id:, user_id:,
                   id:,
                   queue_until: nil, attempts_max: 1)
      user = Models::IAM::Account.find(account_id).users.find(id)

      command = user.commands.create!(
        account_id: account_id,
        user_id: user_id,
        body: Messages::IAM::User::Sync.new(
          user: { id: id }),
        attempts_max: attempts_max,
        queue_until: queue_until)

      [user.tap(&:readonly!), command.tap(&:readonly!)]
    rescue ActiveRecord::RecordNotFound => e
      raise NotFound.new("Not found: #{e.message}")
    rescue ActiveRecord::RecordInvalid => e
      raise Error.new(e.record.errors.full_messages.to_sentence)
    end

    def sync(account_id:, user_id:,
             id:)
      user = Models::IAM::Account.find(account_id).users.find(id)

      event = user.events.create!(
        account_id: account_id,
        user_id: user_id,
        body: Messages::IAM::User::Synced.new(
          user: { id: id }))

      [user.tap(&:readonly!), event.tap(&:readonly!)]
    rescue ActiveRecord::RecordNotFound => e
      raise NotFound.new("Not found: #{e.message}")
    rescue ActiveRecord::RecordInvalid => e
      raise Error.new(e.record.errors.full_messages.to_sentence)
    end
  end
end
