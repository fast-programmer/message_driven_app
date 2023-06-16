module IAM
  module Handlers
    module Handler
      extend self

      def handle(message:, logger:)
        case message.name
        when 'IAM::Messages::User.sync'
          IAM::User.sync(user_id: message.user_id, id: message.messageable_id)
        end
      end
    end
  end
end
