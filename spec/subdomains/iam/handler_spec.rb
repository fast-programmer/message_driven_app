require 'rails_helper'

module IAM
  RSpec.describe Handler do
    let(:user) { Models::User.create!(id: 'user_id', email: 'test@fastprogrammer.co') }

    let(:account) do
      Models::Account.create!(
        id: 'account_id', name: 'Account 1', slug: 'account-1',
        owner_id: user.id, users: [user])
    end

    let(:event) do
      user.events.create!(
        account_id: account.id,
        user_id: user.id,
        body: Messages::User::Sync.new(
          user: { id: user.id }))
    end

    describe '.handle' do
      it 'successfully handles a message' do
        result = Handler.handle(message: event)

        expect(result).equal?({ name: 'IAM::Handler' })
      end
    end
  end
end
