module IAM
  module Handlers
    module User
      module Synced
        def self.handle(message:, logger:)
          logger.info("[##{message.id}] IAM::Handlers::User::Synced> handling #{message.body.class.name}")
          logger.info("[##{message.id}] IAM::Handlers::User::Synced> handled #{message.body.class.name}")
        end
      end
    end
  end
end
