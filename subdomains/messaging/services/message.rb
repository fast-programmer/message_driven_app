module Messaging
  Signal.trap('INT') do
    Message.shutdown

    exit
  end

  module Message
    @is_handling = false

    def self.handle(
      handler:,
      poll:,
      concurrency:,
      queue_id: Models::Queue.default_id,
      logger: Logger.create
    )
      queue = Queue.new

      @is_handling = true

      workers = create_workers(concurrency, queue, logger, handler)
      loop_dequeue_message(queue, logger, queue_id, concurrency, poll)

      workers.each(&:join)
    end

    def self.shutdown
      @is_handling = false
    end

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

        message = dequeue(queue_id: queue_id, current_time: Time.current)

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

        handle_message(message: message, handler: handler, logger: logger, use_connection: true)
      end
    end

    def self.handle_message(message:, logger:, handler:, use_connection: true)
      successful = nil
      started_at = nil
      ended_at = nil
      return_value = nil
      error = nil

      begin
        started_at = Time.current

        return_value = handle_with_optional_connection(
          message: message,
          handler: handler,
          logger: logger,
          use_connection: use_connection)

        ended_at = Time.current

        successful = true
      rescue StandardError => error
        ended_at = Time.current

        successful = false

        logger.error("Exception occurred: #{error.class}: #{error.message}")
        logger.error(error.backtrace.join("\n"))
      end

      if successful
        handled(
          message: message,
          started_at: started_at,
          ended_at: ended_at,
          return_value: return_value)
      else
        failed(
          message: message,
          started_at: started_at,
          ended_at: ended_at,
          error: error)
      end
    end

    def self.handle_with_optional_connection(message:, handler:, logger:, use_connection:)
      if use_connection
        ActiveRecord::Base.connection_pool.with_connection do
          handler.handle(message: message, logger: logger)
        end
      else
        handler.handle(message: message, logger: logger)
      end
    end

    def self.handled(message:, started_at:, ended_at:, return_value:)
      message.attempts_count += 1
      message.status = Models::Message::STATUS[:handled]

      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.transaction do
          message.save!

          message.attempts.create!(
            index: message.attempts_count,
            successful: true,
            started_at: started_at,
            ended_at: ended_at,
            return_value: return_value)
        end
      end

      message
    end

    def self.failed(message:, started_at:, ended_at:, error:)
      message.attempts_count += 1

      if message.attempts_count < message.attempts_max
        message.status = Models::Message::STATUS[:unhandled]
        message.queue_until = calculate_queue_until(message.attempts_count)
      else
        message.status = Models::Message::STATUS[:failed]
      end

      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.transaction do
          message.save!

          message.attempts.create!(
            index: message.attempts_count,
            successful: false,
            started_at: started_at,
            ended_at: ended_at,
            error_class_name: error.class.name,
            error_message: error.message,
            error_backtrace: error.backtrace)
        end
      end

      message
    end

    def self.calculate_queue_until(attempt_count)
      backoff_time = sidekiq_backoff(attempt_count)

      Time.current + backoff_time
    end

    def self.sidekiq_backoff(attempt_count)
      (attempt_count ** 4) + 15 + (rand(30) * (attempt_count))
    end

    def self.dequeue(queue_id:, current_time:)
      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.transaction do
          message = Models::Message
                      .where(queue_id: queue_id)
                      .where(status: Models::Message::STATUS[:unhandled])
                      .where('queue_until IS NULL OR queue_until < ?', current_time)
                      .order(priority: :desc, created_at: :asc)
                      .limit(1)
                      .lock('FOR UPDATE SKIP LOCKED')
                      .first

          message&.update!(status: Models::Message::STATUS[:handling])

          message
        end
      end
    end
  end
end
