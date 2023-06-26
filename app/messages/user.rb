module Messages
  module User
    module_function

    def created(user_id:, email:)
      Models::Messaging::Command.new(
        name: 'User.created',
        user_id: user_id,
        body: { email: email })
    end

    def sync(account_id:, user_id:, tries_max: 1, queue_until: nil)
      Models::Messaging::Command.new(
        name: 'User.sync',
        account_id: account_id,
        user_id: user_id,
        queue_until: queue_until,
        tries_max: tries_max)
    end

    def synced
      Models::Messaging::Event.new(name: 'User.sync')
    end
  end
end
