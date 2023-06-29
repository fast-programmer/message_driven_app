module Messaging
  Signal.trap('INT') do
    Message.shutdown

    exit
  end

  module Message
    @is_handling = false

    def self.handle(
      queue_id: Models::Messaging::Queue.default_id,
      handler:,
      poll:,
      concurrency:
    )
      logger = Logger.create
      queue = Queue.new

      @is_handling = true

      workers = create_workers(concurrency, queue, logger, handler)
      loop_dequeue_message(queue, logger, queue_id, concurrency, poll)

      workers.each(&:join)
    end

    def self.shutdown
      @is_handling = false
    end

    private

    def self.create_workers(concurrency, queue, logger, handler)
      concurrency.times.map do
        Thread.new do
          Thread.current.abort_on_exception = true

          worker_loop(queue, logger, handler)
        end
      end
    end

    def self.loop_dequeue_message(queue, logger, queue_id, concurrency, poll)
      while @is_handling
        unless queue.length < concurrency
          logger.info('queue.length >= concurrency')

          sleep poll

          next
        end

        message = dequeue(queue_id: queue_id, logger: logger, current_time: Time.current)

        unless message
          logger.info('no messages to handle')

          sleep poll

          next
        end

        queue.push(message)
      end
    end


    def self.worker_loop(queue, logger, handler)
      while @is_handling
        message = queue.pop

        handle_message(message, logger, handler)
      end
    end

    def self.handle_message(message, logger, handler)
      return_value = nil
      started_at = Time.current

      ActiveRecord::Base.connection_pool.with_connection do
        begin
          return_value = handler.handle(message: message, logger: logger)
        rescue StandardError => e
          logger.error("Exception occurred: #{e.class}: #{e.message}")
          logger.error(e.backtrace.join("\n"))

          return failed(e, message, started_at, Time.current)
        end

        handled(message, started_at, Time.current, return_value)
      end
    end

    def self.handled(message, started_at, ended_at, return_value)
      message.tries_count += 1
      message.status = Models::Messaging::Message::STATUS[:handled]

      ActiveRecord::Base.transaction do
        message.save!

        message.tries.create!(
          index: message.tries_count, was_successful: true,
          started_at: started_at, ended_at: ended_at,
          return_value: return_value)
      end

      message
    end

    def self.failed(e, message, started_at, ended_at)
      message.tries_count += 1

      if message.tries_count < message.tries_max
        message.status = Models::Messaging::Message::STATUS[:unhandled]
        message.queue_until = calculate_queue_until(message.tries_count)
      else
        message.status = Models::Messaging::Message::STATUS[:failed]
      end

      ActiveRecord::Base.transaction do
        message.save!

        message.tries.create!(
          index: message.tries_count, was_successful: false,
          started_at: started_at, ended_at: ended_at,
          error_class_name: e.class.name, error_message: e.message, error_backtrace: e.backtrace)
      end

      message
    end

    def self.calculate_queue_until(try_count)
      backoff_time = sidekiq_backoff(try_count)

      Time.current + backoff_time
    end

    def self.sidekiq_backoff(try_count)
      (try_count ** 4) + 15 + (rand(30) * (try_count))
    end

    def self.dequeue(queue_id:, logger:, current_time:)
      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.transaction do
          message = Models::Messaging::Message
                      .where(queue_id: queue_id)
                      .where(status: Models::Messaging::Message::STATUS[:unhandled])
                      .where('queue_until IS NULL OR queue_until < ?', current_time)
                      .order(created_at: :asc)
                      .limit(1)
                      .lock('FOR UPDATE SKIP LOCKED')
                      .first

          message&.update!(status: Models::Messaging::Message::STATUS[:handling])

          message
        end
      end
    end
  end
end
