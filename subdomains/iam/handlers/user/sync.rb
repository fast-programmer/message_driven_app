module IAM
  module Handlers
    module User
      module Sync
        def self.handle(message:, logger:)
          logger.info('IAM::Handlers::User::Sync')

          IAM::User.sync(
            account_id: message.account_id,
            user_id: message.user_id,
            id: message.body.user.id)
        end
      end
    end
  end
end
