require 'rails_helper'

module Messaging
  module Handler
    extend self

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

    def can_handle?(message:)
      true
    end
  end

  module Messages
    module Test
      class Tested
        attr_accessor :id

        def self.decode_json(json)
          data = JSON.parse(json)
          obj = self.new(id: data["id"])
          obj
        end

        def initialize(id:)
          @id = id
        end

        def to_json
          {
            "id" => @id
          }.to_json
        end
      end
    end
  end

  RSpec.describe Job do
    let!(:processor_thread) do
      Thread.new do
        Job.process(poll: 1, concurrency: 5)
      end
    end

    after(:each) do
      Job.shutdown

      processor_thread.join
    end

    let(:test) { Models::Test.create!(account_id: 1, user_id: 2) }
    let(:tested_event) { test.events.create!(body: Messages::Test::Tested.new(id: test.id)) }

    it 'processes enqueued jobs' do
      sleep 1

      tested_event.reload
      job = tested_event.jobs.last

      expect(job.status).to eq(Models::Job::STATUS[:processed])
    end

    it 'saves handler return value in last attempt' do
      sleep 2

      attempt = event.jobs.last.attempts.last
      expect(attempt.return_value).to eq(true)
    end
  end
end
