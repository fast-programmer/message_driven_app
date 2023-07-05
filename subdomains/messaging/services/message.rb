module Messaging
  Signal.trap('INT') do
    Message.shutdown

    exit
  end

  module Message
    @is_handling = false

    def self.handle(
      poll:,
      concurrency:,
      queue_id: Models::Queue.default_id,
      logger: Logger.create
    )
      queue = Queue.new

      @is_handling = true

      workers = create_workers(concurrency, queue, logger)
      loop_dequeue_handler_message(queue, logger, queue_id, concurrency, poll)

      workers.each(&:join)
    end

    def self.shutdown
      @is_handling = false
    end

    def self.create_workers(concurrency, queue, logger)
      concurrency.times.map do
        Thread.new do
          Thread.current.abort_on_exception = true

          worker_loop(queue, logger)
        end
      end
    end

    def self.loop_dequeue_handler_message(queue, logger, queue_id, concurrency, poll)
      while @is_handling
        unless queue.length < concurrency
          logger.info('queue.length >= concurrency')

          sleep poll

          next
        end

        handler_message = dequeue(queue_id: queue_id, current_time: Time.current)

        unless handler_message
          logger.info('no messages to handle')

          sleep poll

          next
        end

        queue.push(handler_message)
      end
    end

    def self.worker_loop(queue, logger)
      while @is_handling
        handler_message = queue.pop

        handle_message(handler_message: handler_message, logger: logger, use_connection: true)
      end
    end

    def self.handle_message(handler_message:, logger:, use_connection: true)
      successful = nil
      started_at = nil
      ended_at = nil
      return_value = nil
      error = nil

      begin
        started_at = Time.current

        return_value = handle_with_optional_connection(
          handler_message: handler_message,
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
          handler_message: handler_message,
          started_at: started_at,
          ended_at: ended_at,
          return_value: return_value)
      else
        failed(
          handler_message: handler_message,
          started_at: started_at,
          ended_at: ended_at,
          error: error)
      end
    end

    def self.handle_with_optional_connection(handler_message:, logger:, use_connection:)
      if use_connection
        ActiveRecord::Base.connection_pool.with_connection do
          handler_message.handler.class_name.constantize.send('handle',
            message: handler_message.message,
            logger: logger)
        end
      else
        handler_message.handler.class_name.constantize.send('handle',
          message: handler_message.message,
          logger: logger)
      end
    end

    def self.handled(handler_message:, started_at:, ended_at:, return_value:)
      handler_message.attempts_count += 1
      handler_message.status = Models::HandlerMessage::STATUS[:handled]
      handler_message.delayed_until = nil

      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.transaction do
          handler_message.save!

          handler_message.attempts.create!(
            index: handler_message.attempts_count,
            successful: true,
            started_at: started_at,
            ended_at: ended_at,
            return_value: return_value)
        end
      end

      handler_message
    end

    def self.failed(handler_message:, started_at:, ended_at:, error:)
      handler_message.attempts_count += 1

      if handler_message.attempts_count < handler_message.attempts_max
        handler_message.status = Models::HandlerMessage::STATUS[:delayed]
        handler_message.delayed_until = calculate_delayed_until(handler_message.attempts_count)
      else
        handler_message.status = Models::HandlerMessage::STATUS[:failed]
      end

      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.transaction do
          handler_message.save!

          handler_message.attempts.create!(
            index: handler_message.attempts_count,
            successful: false,
            started_at: started_at,
            ended_at: ended_at,
            error_class_name: error.class.name,
            error_message: error.message,
            error_backtrace: error.backtrace)
        end
      end

      handler_message
    end

    def self.calculate_delayed_until(attempt_count)
      backoff_time = sidekiq_backoff(attempt_count)

      Time.current + backoff_time end

    def self.sidekiq_backoff(attempt_count)
      (attempt_count ** 4) + 15 + (rand(30) * (attempt_count))
    end

    def self.dequeue(queue_id:, current_time:)
      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.transaction do
          handler_message = Models::HandlerMessage
                              .where(queue_id: queue_id)
                              .where(
                                "(status = :unhandled) OR (status = :delayed AND delayed_until < :current_time)",
                                unhandled: Models::HandlerMessage::STATUS[:unhandled],
                                delayed: Models::HandlerMessage::STATUS[:delayed],
                                current_time: current_time)
                              .order(priority: :desc, created_at: :asc)
                              .limit(1)
                              .lock('FOR UPDATE SKIP LOCKED')
                              .first

          handler_message&.update!(
              status: Models::HandlerMessage::STATUS[:handling],
              delayed_until: nil)

          handler_message
        end
      end
    end
  end
end
