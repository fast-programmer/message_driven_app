require_relative 'user'

module MailchimpIntegration
  module Handlers
    module User
      extend self

      def created(message:, logger:)
        sleep(0.2)

        # TODO: list.add_member(email: message.body.email)
      end
    end
  end
end