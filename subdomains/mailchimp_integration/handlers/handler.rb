module MailchimpIntegration
  module Handlers
    module Handler
      extend self

      def handle(message:, logger:)
        case message.body_class_name
        when 'Messages::IAM::User::Created'
          sleep(0.2)
        end
      end
    end
  end
end
