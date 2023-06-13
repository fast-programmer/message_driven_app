require 'rails_helper'

RSpec.describe User do
  self.use_transactional_tests = true

  describe '.create' do
    let(:user) { { email: 'tester@fastprogrammer.co' } }
    let(:event) do
      {
        name: 'User.created',
        body: { 'description' => 'testing' }
      }
    end

    let(:created_user) { User.create(email: user[:email]) }
    let(:last_event) { created_user.events.last }

    it 'creates user' do
      expect(created_user.email).to eq(user[:email])
    end

    it 'creates event' do
      expect(last_event.user_id).to be_present
      expect(last_event.name).to eq(event[:name])
      expect(last_event.body).to be_nil
    end
  end
end
