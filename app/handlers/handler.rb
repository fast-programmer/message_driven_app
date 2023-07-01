module Handlers
  module Handler
    module_function

    def handle(message:, logger:)
      logger.info("message #{message.id} > handling #{message.body.class.name}")

      sleep(rand(1..5))
      # raise StandardError.new('fake error')

      ActiveCampaignIntegration::Handlers::Handler.handle(message: message, logger: logger)
      MailchimpIntegration::Handlers::Handler.handle(message: message, logger: logger)

      logger.info("message #{message.id} > handled #{message.body.class.name}")

      { x: 1, y: 2 }
    end
  end
end
