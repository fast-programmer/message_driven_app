require_relative 'services/user'

module IAM
  module MessageHandler
    extend self

    def call(message:, logger:)
      case message.name
      when 'IAM::Messages::User.sync'
        IAM::User.sync(user_id: message.user_id, id: message.messageable_id)
      end
    end
  end
end
