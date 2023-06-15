require_relative 'active_campaign_integration/message_handler'
require_relative 'mailchimp_integration/message_handler'

module MessageHandler
  module_function

  def handle(message:, logger:)
    logger.info("message #{message.id} > handling #{message.name}")

    ActiveCampaignIntegration::MessageHandler.call(message: message, logger: logger)
    MailchimpIntegration::MessageHandler.call(message: message, logger: logger)

    logger.info("message #{message.id} > handled #{message.name}")
  end
end
