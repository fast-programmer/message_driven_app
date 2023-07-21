require_relative 'handlers/user/sync'
require_relative 'handlers/user/synced'

module IAM
  module Handler
    extend self

    def handlers
      {
        'IAM::Messages::User::Sync' => Handlers::User::Sync,
        'IAM::Messages::User::Synced' => Handlers::User::Synced
      }
    end

    def can_handle?(message:, logger:)
      handlers.has_key?(message.body_class_name)
    end

    def handle(message:, logger:)
      # raise StandardError.new('some error')

      logger.info("[##{message.id}] IAM::Handler> handling #{message.body.class.name}")

      result = handlers[message.body_class_name]&.handle(message: message, logger: logger)

      logger.info("[##{message.id}] IAM::Handler> handled #{message.body.class.name}")

      result
    end
  end
end
