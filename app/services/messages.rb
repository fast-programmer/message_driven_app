require 'concurrent-ruby'

module Messages
  @is_running = true

  def self.shutdown
    @is_running = false
  end

  def self.handle(handler:, sleep_secs: 5, min_threads: 0, max_threads: 2, max_queue: 0)
    executor = Concurrent::ThreadPoolExecutor.new(
      min_threads: min_threads,
      max_threads: max_threads,
      max_queue: max_queue,
      fallback_policy: :caller_runs
    )

    while @is_running do
      remaining_capacity = max_threads - executor.queue_length - executor.length

      if remaining_capacity <= 0
        puts 'Executor at full capacity, sleeping...'
        sleep sleep_secs
        next
      end

      messages = slice(0, remaining_capacity)

      if messages.empty?
        puts 'No messages found, sleeping...'
        sleep sleep_secs
        next
      end

      messages.each do |message|
        executor.post do
          begin
            handler.handle(message: message)

            message.update!(status: Message::STATUS[:handled])
          rescue StandardError => e
            message.update!(status: Message::STATUS[:failed])

            puts "An error occurred while handling message #{message.id}: #{e.message}"

            raise
          end
        end
      end

      executor.shutdown
      executor.wait_for_termination
    end
  end

  def self.slice(start, length)
    ActiveRecord::Base.transaction do
      message_ids = Models::Message
                      .where(status: Message::STATUS[:unhandled])
                      .order(created_at: :asc)
                      .offset(start)
                      .limit(length)
                      .lock('FOR UPDATE SKIP LOCKED')
                      .pluck(:id)

      return [] unless message_ids.any?

      updated_count = Models::Message
                        .where(id: message_ids, status: Message::STATUS[:unhandled])
                        .update_all(status: Message::STATUS[:handling])

      if updated_count != message_ids.size
        raise "Expected to update #{message_ids.size} records, but only updated #{updated_count} records."
      end

      messages = Models::Message.where(id: message_ids, status: Message::STATUS[:handling]).to_a

      if messages.size != message_ids.size
        raise "Expected to find #{message_ids.size} records, but only find #{messages.size} records."
      end

      messages
    end
  end

  private_class_method :slice
end
