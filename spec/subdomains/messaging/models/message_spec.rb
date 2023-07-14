require 'rails_helper'

module Messaging
  module Models
    RSpec.describe Message do
      let(:account_id) { 1 }
      let(:user_id) { 1 }
      let(:queue) { Models::Queue.default }
      let(:handler) do
        Models::Handler.create!(
          queue_id: queue_id,
          slug: 'messaging',
          name: 'Messaging',
          class_name: 'Messaging::Handler',
          enabled: true)
      end

      let(:event) do
        user.events.create!(
          account_id: account.id,
          user_id: user.id,
          body: Messages::User::Sync.new(user: { id: user.id }))
      end

      describe '.events.create!' do
        let(:event) { user.events.create!() }

        it 'creates event' do
          # expect(event).toEqual(...)
        end

        it 'creates jobs' do
          expect(event.jobs).toEqual([
            { handler_class_name, message_id },
            { handler_class_name, message_id },
          ])
        end
      end
    end
  end
end
