require_relative '../messages/user'

module Account
  module_function

  class Error < StandardError; end
  class NotFound < StandardError; end

  def create(name:, slug:, owner_id:, queue_id: Rails.cache.read('queue').id)
    user = Models::User.find(owner_id)

    ActiveRecord::Base.transaction do
      account = Models::Account.create!(name: name, slug: slug, owner_id: owner_id, users: [user])
      account_created_event = Messages::Account.created(name: name, slug: slug, owner_id: owner_id)

      account.events.create!(
        queue_id: Queues.Default.id,
        account: account,
        user: user,
        name: account_created_event.name,
        body: account_created_event.body
      )

      account.readonly!
      account.freeze

      account
    end
  rescue ActiveRecord::RecordInvalid => e
    raise Error.new(e.record.errors.full_messages.to_sentence)
  rescue ActiveRecord::RecordNotUnique => e
    raise Error.new("Database error: #{e.message}")
  end
end
