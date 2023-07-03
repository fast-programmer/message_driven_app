module MailchimpIntegration
  module Handlers
    module Handler
      extend self

      def handle(message:, logger:)
        logger.info("MailchimpIntegration::Handler> message #{message.id} handling #{message.body.class.name}")

        # raise StandardError.new('MailchimpIntegration::Handler> fake error')

        case message.body_class_name
        when 'IAM::Messages::User::Created'
          sleep(0.2)
        end

        logger.info("MailchimpIntegration::Handler> message #{message.id} handled #{message.body.class.name}")

        { name: 'MailchimpIntegration::Handler' }
      end
    end
  end
end
