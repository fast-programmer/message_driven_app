require_relative 'user'

module IAM
  module Handlers
    module User
      extend self

      def created(message:, logger:)
        sleep(0.2)

        # TODO: Contact.create(email: message.body.email)
      end
    end
  end
end
