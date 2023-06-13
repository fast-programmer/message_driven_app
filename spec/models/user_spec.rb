require 'rails_helper'

RSpec.describe User, type: :model do
  self.use_transactional_tests = true

  let(:email) { 'test@example.com' }

  it 'creates and retrieves a user with the correct attributes' do
    created_user = User.create(email: email)

    found_user = User.find(created_user.id)

    expect(found_user.email).to eq(email)
  end
end
