require 'rails_helper'

module IAM
  RSpec.describe User do
    describe '.create' do
      # let(:handler) do
      #   Models::Handler.create!(
      #     queue_id: Models::Queue.default_id,
      #     slug: 'iam',
      #     name: 'IAM',
      #     class_name: 'IAM::Handler',
      #     enabled: true)
      # end

      context 'when valid params are passed' do
        let(:email) { 'test@example.com' }

        let(:results) { User.create(email: email) }
        let(:user) { results[0] }
        let(:event) { results[1] }

        it 'returns user' do
          expect(user.email).to eq(email)
          expect(user.readonly?).to be_truthy
        end

        it 'returns event' do
          expect(event.readonly?).to be_truthy
        end

        it 'creates job to call handler' do
          # expect(event.jobs[0].handler_class_name).toEqual(handler.class_name)

          # expect(event.jobs[0].handler).toEqual(IAM::Handler)
        end
      end

      context 'when invalid params are passed' do
        it 'raises an Error' do
          expect { User.create(email: nil) }.to raise_error(User::Error)
        end
      end

      context 'when unique constraint is violated' do
        let(:email) { 'test@example.com' }

        it 'raises an Error' do
          User.create(email: email)
          expect { User.create(email: email) }.to raise_error(User::Error)
        end
      end
    end
  end
end
