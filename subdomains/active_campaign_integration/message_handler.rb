require_relative 'message_handler/iam/user'

module ActiveCampaignIntegration
  module MessageHandler
    extend self

    def call(message:, logger:)
      case message.name
      when 'IAM::Messages::User.created'
        IAM::User.created(message: message, logger: logger)
      end
    end
  end
end
