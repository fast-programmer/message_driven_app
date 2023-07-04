require 'rails_helper'

module IAM
  RSpec.describe Handler do
    let(:user) { Models::User.create(id: 'user_id') }
    let(:account) { Models::Account.create(id: 'account_id', users: [user]) }
    let(:event) do
      user.events.create(
        account_id: account.id,
        user_id: user.id,
        body: Messages::User::Synced.new(
          user: { id: user.id }))
    end

    let(:logger) { Logger.new(STDOUT) }

    describe '.handle' do
      it 'successfully handles a message' do
        IAM::Handler.handle(message: message, logger: logger)

        expect(event).to be_persisted
      end
    end
  end
end
