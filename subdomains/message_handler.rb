require_relative 'active_campaign_integration/message_handler'
require_relative 'mailchimp_integration/message_handler'

module MessageHandler
  module_function

  def handle(message:, stdout_logger:, stderr_logger:)
    stdout_logger.info("Handling message #{message.id}: #{message.name}")

    ActiveCampaignIntegration::MessageHandler.call(message: message)
    MailchimpIntegration::MessageHandler.call(message: message)

    stdout_logger.info("Handled message #{message.id}: #{message.name}")
  end
end
