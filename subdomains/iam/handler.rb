require_relative 'handlers/user/sync'

module IAM
  module Handler
    extend self

    def routes
      {
        'IAM::Messages::User::Sync' => 'IAM::Handlers::User::Sync'
      }
    end

    def handles?(message:)
      routes.has_key?(message: message.class.name)
    end

    def handle(message:, logger:)
      logger.info("IAM::Handler> message #{message.id} handling #{message.body.class.name}")

      message.body_class_name.constantize
        .handle(
          account_id: message.account_id,
          user_id: message.user_id,
          id: message.body.user.id)

      logger.info("IAM::Handler> message #{message.id} handled #{message.body.class.name}")

      { name: 'IAM::Handler' }
    end
  end
end
