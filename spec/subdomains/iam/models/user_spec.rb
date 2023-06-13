require 'rails_helper'

module IAM
  module Models
    RSpec.describe User, type: :model do
      self.use_transactional_tests = true

      let(:user) { { email: 'tester@fastprogrammer.co' } }
      let(:event) do
        {
          name: 'User.created',
          body: { 'description' => 'testing' }
        }
      end

      it 'creates and retrieves a user with the correct attributes' do
        created_user = User.create(email: user[:email])
        created_event = created_user.events.create!(
          user_id: created_user.id, name: event[:name], body: event[:body]
        )

        found_user = User.find(created_user.id)
        found_event = found_user.events.find(created_event.id)

        expect(found_event.user_id).to eq(created_event.user_id)
        expect(found_user.email).to eq(user[:email])
        expect(found_event.name).to eq(event[:name])
        expect(found_event.body).to eq(event[:body])
      end
    end
  end
end
