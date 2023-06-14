require_relative 'active_campaign_integration/message_handler'
require_relative 'mailchimp_integration/message_handler'

module MessageHandler
  module_function

  def handle(message:)
    puts "Handling message #{message.id}: #{message.name}"

    ActiveCampaignIntegration::MessageHandler.call(message: message)
    MailchimpIntegration::MessageHandler.call(message: message)

    puts "Handled message #{message.id}: #{message.name}"
  end
end
