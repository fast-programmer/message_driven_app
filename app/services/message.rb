require 'concurrent-ruby'

module Message
  STATUS = Models::Message::STATUS

  def self.handle(handler:, concurrency: 1)
    executor = Concurrent::ThreadPoolExecutor.new(
      min_threads: 0,
      max_threads: concurrency,
      max_queue: concurrency * 2,
      fallback_policy: :caller_runs
    )

    loop do
      message = splice(0, concurrency)

      executor.post do
        if message
          begin
            handler.handle(message: message)

            message.update!(status: Message::STATUS[:handled])
          rescue StandardError => e
            message.update!(status: Message::STATUS[:failed])

            puts "An error occurred while handling message #{message.id}: #{e.message}"

            raise
          end
        else
          puts 'No unhandled messages found, sleeping...'

          sleep 1
        end
      end
    end
  end

  def self.splice(start, limit)
    ActiveRecord::Base.transaction do
      message_ids = Models::Message
                      .where(status: STATUS[:unhandled])
                      .order(created_at: :asc)
                      .offset(start)
                      .limit(limit)
                      .lock('FOR UPDATE SKIP LOCKED')
                      .pluck(:id)

      if message_ids.any?
        updated_count = Models::Message
                          .where(id: message_ids, status: STATUS[:unhandled])
                          .update_all(status: STATUS[:handling])

        if updated_count != message_ids.size
          raise "Expected to update #{message_ids.size} records, but only updated #{updated_count} records."
        end

        messages = Models::Message
                     .where(id: message_ids, status: STATUS[:handling])
                     .to_a

        if messages.size != message_ids.size
          raise "Expected to find #{message_ids.size} records, but only find #{messages.size} records."
        end

        messages

      else
        []
      end
    end
  end

  private_class_method :shift
end
