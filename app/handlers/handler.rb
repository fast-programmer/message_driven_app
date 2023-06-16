module Handlers
  module Handler
    module_function

    def handle(message:, logger:)
      logger.info("message #{message.id} > handling #{message.name}")

      IAM::Handlers::Handler.handle(message: message, logger: logger)
      ActiveCampaignIntegration::Handlers::Handler.handle(message: message, logger: logger)
      MailchimpIntegration::Handlers::Handler.handle(message: message, logger: logger)

      logger.info("message #{message.id} > handled #{message.name}")
    end
  end
end
