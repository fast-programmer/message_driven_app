module IAM
  module Handlers
    module User
      module Sync
        extend self

        def handle(message:, logger:)
          User.sync(
            account_id: message.account_id,
            user_id: message.user_id,
            id: message.body.user.id)
        end
      end
    end
  end
end
