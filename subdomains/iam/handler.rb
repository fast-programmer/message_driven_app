require_relative 'handlers/user/sync'
require_relative 'handlers/user/synced'

module IAM
  module Handler
    extend self

    def routes
      {
        'IAM::Messages::User::Sync' => Handlers::User::Sync,
        'IAM::Messages::User::Synced' => Handlers::User::Synced
      }
    end

    def handles?(message:)
      routes.has_key?(message.body_class_name)
    end

    def handle(message:, logger: Logger.new(STDOUT))
      logger.info("IAM::Handler> message #{message.id} handling #{message.body.class.name}")

      routes[message.body_class_name].handle(message: message, logger: logger)

      logger.info("IAM::Handler> message #{message.id} handled #{message.body.class.name}")

      { name: 'IAM::Handler' }
    end
  end
end
