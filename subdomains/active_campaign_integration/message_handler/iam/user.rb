module ActiveCampaignIntegration
  module MessageHandler
    module IAM
      module User
        extend self

        def created(message:)
          # puts('called message handler: ActiveCampaignIntegration::IAM::User.created')

          # TODO: Contact.create(email: message.body.email)
        end
      end
    end
  end
end
