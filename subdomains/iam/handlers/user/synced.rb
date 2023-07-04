module IAM
  module Handlers
    module User
      module Synced
        def self.handle(message:, logger:)
          logger.info('IAM::Handlers::User::Synced')
        end
      end
    end
  end
end
