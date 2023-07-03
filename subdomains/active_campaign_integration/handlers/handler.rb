module ActiveCampaignIntegration
  module Handlers
    module Handler
      extend self

      def handle(message:, logger:)
        logger.info("ActiveCampaignIntegration::Handler> handling message #{message.id} #{message.body.class.name}")

        case message.body_class_name
        when 'IAM::Messages::User::Created'
          sleep(0.2)
        end

        logger.info("ActiveCampaignIntegration::Handler> handled message #{message.id} #{message.body.class.name}")

        { name: 'ActiveCampaignIntegration::Handler' }
      end
    end
  end
end
