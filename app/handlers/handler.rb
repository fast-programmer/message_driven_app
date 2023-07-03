module Handlers
  module Handler
    module_function

    def handle(message:, logger:)
      logger.info("message #{message.id} > handling #{message.body.class.name}")

      # sleep(rand(1..5))
      # raise StandardError.new('fake error')

      case message.body_class_name
      when 'IAM::Messages::Handler::Handle'
        IAM::Handlers::Handler.handle(message: message, logger: logger)
      when 'ActiveCampaignIntegration::Messages::Handler::Handle'
        ActiveCampaignIntegration::Handlers::Handler.handle(message: message, logger: logger)
      when 'MailchimpIntegration::Messages::Handler::Handle'
        MailChimpIntegration::Handlers::Handler.handle(message: message, logger: logger)
      end

      logger.info("message #{message.id} > handled #{message.body.class.name}")

      { x: 1, y: 2 }
    end
  end
end
