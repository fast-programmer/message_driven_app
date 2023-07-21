module MailchimpIntegration
  module Handler
    extend self

    def handlers
      {}
    end

    def can_handle?(message:)
      handlers.has_key?(message.body_class_name)
    end

    def handle(message:, logger:)
      # raise StandardError.new('some error')

      logger.info("[##{message.id}] MailchimpIntegration::Handler> message #{message.id} handling #{message.body.class.name}")

      result = handlers[message.body_class_name].constantize.handle(message: message, logger: logger)

      logger.info("[##{message.id}] MailchimpIntegration::Handler> message #{message.id} handled #{message.body.class.name}")

      result
    end
  end
end
