require_relative 'user'

module ActiveCampaignIntegration
  module Handlers
    module Handler
      extend self

      def handle(message:, logger:)
        case message.name
        when 'Messages::User.created'
          User.created(message: message, logger: logger)
        end
      end
    end
  end
end
