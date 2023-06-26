module Messages
  module Account
    module_function

    def created(account_id:, user_id:, name:, slug:, owner_id:)
      Models::Messaging::Event.new(
        name: 'Account.created',
        account_id: account_id,
        user_id: user_id,
        body: { name: name, slug: slug, owner_id: owner_id })
    end
  end
end
