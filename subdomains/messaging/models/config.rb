module Messaging
  module Models
    class Config
      attr_accessor :defaults

      def initialize
        @defaults = {
          jobs: {
            poll: 1,
            concurrency: 5,
            queue_id: 1
          },
          job: {
            queue_id: 1,
            priority: 0,
            process_at: nil,
            attempts: {
              max: 1,
              error: {
                persist: true,
                backtrace: {
                  persist: true,
                  lines: {
                    max: 100,
                    order: :asc
                  }
                },
                backoff: ->(current_time:, current_attempt:) do
                  current_time + (attempt_count ** 4) + 15 + (rand(30) * (current_attempt.index))
                end
              },
              result: { persist: true },
              processed: { remove: true }
            }
          }
        }
      end
    end
  end
end
