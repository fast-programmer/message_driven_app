module MailchimpIntegration
  module Handler
    extend self

    def routes
      {}
    end

    def handles?(message:)
      routes.has_key?(message.body_class_name)
    end

    def handle(message:, logger: Logger.new(STDOUT))
      logger.info("[##{message.id}] MailchimpIntegration::Handler> message #{message.id} handling #{message.body.class.name}")

      # routes[message.body_class_name].constantize.handle(
      #   message: message, logger: logger)

      logger.info("[##{message.id}] MailchimpIntegration::Handler> message #{message.id} handled #{message.body.class.name}")

      { name: 'MailchimpIntegration::Handler' }
    end
  end
end
