require 'rails_helper'

RSpec.describe 'Message Publisher Script', type: :integration do
  let(:user) { User.create(email: 'tester@fastprogrammer.co') }
  let(:message_publisher_script) { "#{Rails.root}/bin/message_publisher" }

  it 'publishes an unpublished message' do
    # pid = fork { exec("RAILS_ENV=#{ENV['RAILS_ENV']} #{message_publisher_script}") }
    # puts 'forked'

    # sleep 5
    # puts 'slept 5 seconds'

    # Process.kill('SIGTERM', pid)
    # puts 'killed'

    # expect(message.reload.status).to eq(Message::STATUS[:published])
  end
end
