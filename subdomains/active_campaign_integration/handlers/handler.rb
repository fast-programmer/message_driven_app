require_relative 'user'

module ActiveCampaignIntegration
  module Handlers
    module Handler
      extend self

      def handle(message:, logger:)
        case message.body_class_name
        when 'Messages::User::Created'
          User.created(message: message, logger: logger)
        end
      end
    end
  end
end
