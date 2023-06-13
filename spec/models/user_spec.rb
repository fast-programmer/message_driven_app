require 'rails_helper'

RSpec.describe User, type: :model do
  self.use_transactional_tests = true

  let(:user) do
    { email: 'tester@fastprogrammer.co' }
  end

  let(:event) do
    {
      name: 'User.created',
      body: { 'description' => 'testing' }
    }
  end

  it 'creates and retrieves a user with the correct attributes' do
    created_user = User.create(email: user[:email])
    created_event = created_user.events.create!(name: event[:name], body: event[:body])

    found_user = User.find(created_user.id)
    found_event = found_user.events.find(created_event.id)

    expect(found_user.email).to eq(user[:email])
    expect(found_event.name).to eq(event[:name])
    expect(found_event.body).to eq(event[:body])
  end
end
