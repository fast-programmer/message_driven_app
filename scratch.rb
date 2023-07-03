def self.log_connection_pool_stats(logger:)
  stats = ActiveRecord::Base.connection_pool.stat

  log_hash = {
    Size: stats[:size],
    Connections: stats[:connections],
    Busy: stats[:busy],
    Idle: stats[:idle],
    Waiting: stats[:waiting],
    CheckoutTimeout: stats[:checkout_timeout]
  }

  log_message = log_hash.map { |k, v| "#{k}: #{v}" }.join(', ')

  logger.info log_message
end

# IAM::Handlers::Handler.handle_async(message: message, logger: logger)
# ActiveCampaignIntegration::Handlers::Handler.handle_async(message: message, logger: logger)
# MailchimpIntegration::Handlers::Handler.handle_async(message: message, logger: logger)


# iam_handler = Messaging::Models::Handler.find_by!(name: 'iam', class_name: 'IAM::Handler', method: 'handle')


# user.messages[0].handlers[0].attempts

# iam_handler = Messaging::Models::Handler.find_by!(name: 'IAM handler')

# iam_handler.commands.create!(
#   account_id: message.account_id,
#   user_id: message.user_id,
#   queue_id: message.queue_id,
#   body: IAM::Messages::Handler::Handle.new(
#     original_message_id: message.id))

# active_campaign_integration_handler = Messaging::Models::Handler.find_by!(
#   name: 'Active Campaign Integration handler')

# active_campaign_integration_handler.commands.create!(
#   account_id: message.account_id,
#   user_id: message.user_id,
#   queue_id: message.queue_id,
#   body: ActiveCampaignIntegration::Messages::Handler::Handle.new(
#     original_message_id: message.id))

# mailchimp_integration_handler = Messaging::Models::Handler.find_by!(
#   name: 'Mailchimp Integration handler')

# mailchimp_integration_handler.commands.create!(
#   account_id: message.account_id,
#   user_id: message.user_id,
#   queue_id: message.queue_id,
#   body: MailchimpIntegration::Messages::Handler::Handle.new(
#     original_message_id: message.id))


# subdomain_handlers = [
#   iam_handler,
#   active_campaign_integration_handler,
#   mailchimp_integration_handler
# ]

# user.messages[0].handlers << subdomain_handlers
