module MailchimpIntegration
  module MessageHandler
    module IAM
      module User
        extend self

        def created(message:)
          console.log('called message handler: MailchimpIntegration::IAM::User.created')

          # TODO: list.add_member(email: message.body.email)
        end
      end
    end
  end
end
