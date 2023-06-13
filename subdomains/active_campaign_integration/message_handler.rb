require_relative 'message_handler/iam/user'

module ActiveCampaignIntegration
  module MessageHandler
    extend self

    def call(message:)
      case message.name
      when 'IAM::User.created'
        IAM::User.created(message: message)
      end
    end
  end
end
