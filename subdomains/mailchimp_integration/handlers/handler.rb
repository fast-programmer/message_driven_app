require_relative 'iam/user'

module MailchimpIntegration
  module Handlers
    module Handler
      extend self

      def handle(message:, logger:)
        case message.name
        when 'IAM::Messages::User.created'
          IAM::User.created(message: message, logger: logger)
        end
      end
    end
  end
end
