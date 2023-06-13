require 'rails_helper'

RSpec.describe 'Publisher Script', type: :integration do
  let(:message) { Message.create!(name: 'Test') }
  let(:publisher_script) { "#{Rails.root}/bin/publisher" }

  it 'publishes an unpublished message' do
    pid = fork { exec("RAILS_ENV=#{ENV['RAILS_ENV']} #{publisher_script}") }
    puts 'forked'

    sleep 5
    puts 'slept 5 seconds'

    Process.kill('SIGTERM', pid)
    puts 'killed'

    expect(message.reload.status).to eq(Message::STATUS[:published])
  end
end
