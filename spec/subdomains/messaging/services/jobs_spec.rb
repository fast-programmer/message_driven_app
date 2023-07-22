require 'rails_helper'

module Messaging
  module Handler
    extend self

    def options(current_time: Time.current)
      {
        priority: 1,
        processed: { destroy: true },
        attempts: {
          max: 3,
          error: {
            backtrace: {
              lines: {
                max: 100
              }
            }
          },
          result: { enabled: true }
        }
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

        def initialize(id:)
          @id = id
        end

        def to_json
          {
            "id" => @id
          }.to_json
        end

        def self.decode_json(json)
          data = JSON.parse(json)

          self.new(id: data["id"])
        end
      end
    end
  end

  RSpec.describe Jobs do
    let!(:process_jobs_thread) do
      Thread.new do
        Jobs.process(poll: 1, concurrency: 5)
      end
    end

    let!(:publisher) { Models::Publisher.create!(handler: Handler.handle) }

    after(:each) do
      Jobs.shutdown

      process_jobs_thread.join
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
      expect(attempt.result).to eq(true)
    end
  end
end
