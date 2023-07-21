require 'rails_helper'

module Messaging
  # class Test
  #   def tested

  #   end
  # end

  module TestHandler
    module_funtion

    def options
      {
        attempts_max: 5,
        priority: 1,
        backoff: -> (current_time:, attempt_index:) { current_time + attempt_index },
        run_at: -> (current_time:) { current_time + 1.second }
      }
    end

    def handle(message:, logger:)
      true
    end

    def handles?(message:)
      true
    end
  end

  RSpec.describe Job do
    let(:user_id) { 1 }
    let(:account_id) { 1 }

    # let(:logger) { Logger.create }
    # let(:queue_id) { Models::Queue.default_id }

    # let(:test) do
    #   Models::Command.create!(
    #     account_id: 1,
    #     user_id: 1,
    #     messagable_id: 1,
    #     messageable_type: 'Messaging::Models::Test',
    #     body: Messaging::Test::Tested.build(name: 'Test')
    # end

    # let(:message) do
    #   Models::Command.create!(
    #     account_id: 1,
    #     user_id: 1,
    #     messagable_id: 1,
    #     messageable_type: 'Messaging::Test',
    #     body: Messaging::Test::Tested.build
    # end

    # body_class_name: 'Messaging::Test::Tested',
    # body_json: {},

    let(:test) { Models::Test.create!(account_id: account_id, user_id: user_id) }
    let(:message) { test.messages.create!(body: Messaging::Test::Tested.build }

    it "processes enqueued jobs" do
      expect(TestHandler).to receive(:handle).with(hash_including(message: 'Test message')).and_call_original

      processing_thread = Thread.new do
        Job.process(poll: 1, concurrency: 1, logger: logger)
      end

      message.jobs.create!(handler: TestHandler.handle)

      # Models::Job.create!(
      #   message: message)

      # merged_options = options.merge(TestHandler.options)

      # handle_at: TestHandler.options.handle_at(current_time: Time.current),
      # priority: TestHandler.options.priority || Job.options.priority,
      # attempts_max: TestHandler.options.attempts_max || Job.options.attempts_max,

      sleep 3

      job = Models::Job.order(created_at: :desc).first
      expect(job.status).to eq(Models::Job::STATUS[:processed])

      Job.shutdown
      processing_thread.join

      expect(processing_thread.alive?).to eq(false)

      attempt = job.attempts.order(created_at: :desc).first
      expect(attempt.return_value).to eq(true)
    end
  end
end

IAM::User #1:
  Messages:
  - IAM::User::Created
    Jobs:
    - Handler [handled: 1/1] (default)
    - IAM::Handler [scheduled: 2/3] (default)
    - ActiveCampaignIntegration::Handler [queued: 0/3] (active_campaign)
    - MailchimpIntegration::Handler [queued: 0/3] (default)

  - IAM::User::Updated
    Jobs:
    - Handler [handled: 1/1] (default)
    - IAM::Handler [scheduled: 2/3] (default)
    - ActiveCampaignIntegration::Handler [queued: 0/3] (active_campaign)
    - MailchimpIntegration::Handler [queued: 1/3] (default)
    - MailchimpIntegration::Contact::Create [queued: 0/3] (default)
