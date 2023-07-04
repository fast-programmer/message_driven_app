module IAM
  module Handlers
    module User
      module Sync
        def self.handle(message:, logger:)
          logger.info("[##{message.id}] IAM::Handlers::User::Sync> handling #{message.body.class.name}")

          IAM::User.sync(
            account_id: message.account_id,
            user_id: message.user_id,
            id: message.body.user.id)

          logger.info("[##{message.id}] IAM::Handlers::User::Sync> handled #{message.body.class.name}")
        end
      end
    end
  end
end
