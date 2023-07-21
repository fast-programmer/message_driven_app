module ActiveCampaignIntegration
  module Handler
    extend self

    def handlers
      {}
    end

    def handles?(message:, logger:)
      handlers.has_key?(message.body_class_name)
    end

    def handle(message:, logger:)
      logger.info("[##{message.id}] ActiveCampaignIntegration::Handler> message #{message.id} handling #{message.body.class.name}")

      result = handlers[message.body_class_name].constantize.handle(message: message, logger: logger)

      logger.info("[##{message.id}] ActiveCampaignIntegration::Handler> message #{message.id} handled #{message.body.class.name}")

      result
    end
  end
end
