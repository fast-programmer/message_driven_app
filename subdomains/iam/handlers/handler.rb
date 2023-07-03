module IAM
  module Handlers
    module Handler
      extend self

      def handle(message:, logger:)
        logger.info("IAM::Handler> message #{message.id} handling #{message.body.class.name}")

        case message.body_class_name
        when 'IAM::Messages::User::Sync'
          User.sync(
            account_id: message.account_id,
            user_id: message.user_id,
            id: message.body.user.id)
        end

        logger.info("IAM::Handler> message #{message.id} handled #{message.body.class.name}")

        { name: 'IAM::Handler' }
      end
    end
  end
end
