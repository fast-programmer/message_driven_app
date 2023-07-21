module Handler
  extend self

  def options
    {
      attempts_max: 1,
      priority: 0
    }
  end

  def handle(message:, logger:)
    logger.info("[##{message.id}] Handler> message #{message.id} handling #{message.body.class.name}")

    handlers = [
      IAM::Handler,
      ActiveCampaignIntegration::Handler,
      MailchimpIntegration::Handler
    ].select do |handler|
      !handler.respond_to?("can_#{handler.method_name}?") ||
        !handler.send("can_#{handler.method_name}?", message: message)
    end

    Transaction.execute do
      handlers.map do |handler|
          jobs.create!(handler: handler, attempts_max: 1)
        end
      end
    end unless handlers.empty?

    logger.info("[##{message.id}] Handler> message #{message.id} handled #{message.body.class.name}")
  end
end
