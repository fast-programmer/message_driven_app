require 'rails_helper'

RSpec.describe Message, type: :model do
  self.use_transactional_tests = true

  let(:name) { 'User.create' }
  let(:status) { 'unprocessed' }
  let(:body) { { 'key' => 'value' } }

  it 'creates and retrieves a message with the correct attributes' do
    created_message = Message.create(name: name, status: status, body: body)

    found_message = Message.find(created_message.id)

    expect(found_message.name).to eq(name)
    expect(found_message.status).to eq(status)
    expect(found_message.body).to eq(body)
  end
end
