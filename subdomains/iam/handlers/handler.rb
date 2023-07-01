require_relative 'user'

module IAM
  module Handlers
    module Handler
      extend self

      def handle(message:, logger:)
        case message.body_class_name
        when 'Messages::User::Sync'
          User.sync(
            account_id: message.account_id,
            user_id: message.user_id,
            id: message.body.user.id)
        end
      end
    end
  end
end
