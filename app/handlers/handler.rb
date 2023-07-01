module Handlers
  module Handler
    module_function

    def handle(message:, logger:)
      logger.info("message #{message.id} > handling #{message.body.class.name}")

      # sleep(rand(1..5))
      # raise StandardError.new('fake error')

      case message.body_class_name
      when 'Messages::User::Sync'
        User.sync(
          account_id: message.account_id,
          user_id: message.user_id,
          id: message.body.user.id)
      end

      ActiveCampaignIntegration::Handlers::Handler.handle(message: message, logger: logger)
      MailchimpIntegration::Handlers::Handler.handle(message: message, logger: logger)

      logger.info("message #{message.id} > handled #{message.body.class.name}")

      { x: 1, y: 2 }
    end
  end
end
