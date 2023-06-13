module ActiveCampaignIntegration
  module MessageHandler
    module IAM
      module User
        extend self

        def created(message:)
          # TODO: Contact.create(email: message.body.email)
        end
      end
    end
  end
end
