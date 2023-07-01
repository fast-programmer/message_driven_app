require_relative 'user'

module Handlers
  module User
    extend self

    def created(message:, logger:)
      user, event = User.sync(
        account_id: message.account_id,
        user_id: message.user_id,
        id: user.id,
        queue_until: Time.current + 5.seconds,
        attempts_max: 2)
    end
  end
end
