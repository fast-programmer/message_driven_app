module Messaging
  Signal.trap('INT') do
    Message.shutdown

    exit
  end

  module Job
    @is_handling = false

    def self.default_queue_id
      ActiveRecord::Base.connection_pool.with_connection do
        Models::Queue.default_id
      end
    end

    def self.process(
      poll:,
      concurrency:,
      queue_id: default_queue_id,
      logger: Logger.create
    )
      queue = Queue.new

      @is_handling = true

      workers = create_workers(concurrency, queue, logger)
      loop_dequeue_job(queue, logger, queue_id, concurrency, poll)

      workers.each(&:join)
    end

    def self.shutdown
      @is_handling = false end

    def self.create_workers(concurrency, queue, logger)
      concurrency.times.map do
        Thread.new do
          Thread.current.abort_on_exception = true

          worker_loop(queue, logger)
        end
      end
    end

    def self.loop_dequeue_job(queue, logger, queue_id, concurrency, poll)
      while @is_handling
        unless queue.length < concurrency
          logger.debug('queue.length >= concurrency')

          sleep poll

          next
        end

        job = dequeue(queue_id: queue_id, current_time: Time.current, logger: logger)

        unless job
          logger.debug('no messages to handle')

          sleep poll

          next
        end

        queue.push(job)
      end
    end

    def self.worker_loop(queue, logger)
      while @is_handling
        job = queue.pop

        process_job(job: job, logger: logger)
      end
    end

    def self.process_job(job:, logger:)
      successful = nil
      started_at = nil
      ended_at = nil
      return_value = nil
      error = nil

      begin
        started_at = Time.current

        begin
          job.handler_class_name.constantize.send(
            'handle',
            message: job.message,
            logger: logger)
        ensure
          ActiveRecord::Base.clear_active_connections!
        end

        ended_at = Time.current

        successful = true
      rescue StandardError => error
        ended_at = Time.current

        successful = false

        logger.error("Exception occurred: #{error.class}: #{error.message}")
        logger.error(error.backtrace.join("\n"))
      end

      if successful
        processed(
          job: job,
          started_at: started_at,
          ended_at: ended_at,
          return_value: return_value)
      else
        failed(
          job: job,
          started_at: started_at,
          ended_at: ended_at,
          error: error)
      end
    end

    def self.processed(job:, started_at:, ended_at:, return_value:)
      job.attempts_count += 1
      job.status = Models::Job::STATUS[:processed]
      job.scheduled_for = nil

      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.transaction do
          job.save!

          job.attempts.create!(
            index: job.attempts_count,
            successful: true,
            started_at: started_at,
            ended_at: ended_at,
            return_value: return_value)
        end
      end

      job
    end

    def self.failed(job:, started_at:, ended_at:, error:)
      job.attempts_count += 1

      if job.attempts_count < job.attempts_max
        job.status = Models::Job::STATUS[:scheduled]
        job.scheduled_for = calculate_scheduled_for(job.attempts_count)
      else
        job.status = Models::Job::STATUS[:failed]
      end

      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.transaction do
          job.save!

          job.attempts.create!(
            index: job.attempts_count,
            successful: false,
            started_at: started_at,
            ended_at: ended_at,
            error_class_name: error.class.name,
            error_message: error.message,
            error_backtrace: error.backtrace)
        end
      end

      job
    end

    def self.calculate_scheduled_for(attempt_count)
      backoff_time = sidekiq_backoff(attempt_count)

      Time.current + backoff_time end

    def self.sidekiq_backoff(attempt_count)
      (attempt_count ** 4) + 15 + (rand(30) * (attempt_count))
    end

    def self.dequeue(queue_id:, current_time:, logger:)
      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.transaction do
          job = Models::Job
                              .where(queue_id: queue_id)
                              .where(
                                "(status = :queued) OR (status = :scheduled AND scheduled_for < :current_time)",
                                queued: Models::Job::STATUS[:queued],
                                scheduled: Models::Job::STATUS[:scheduled],
                                current_time: current_time)
                              .order(priority: :desc, created_at: :asc)
                              .limit(1)
                              .lock('FOR UPDATE SKIP LOCKED')
                              .first

          job&.update!(
              status: Models::Job::STATUS[:processing],
              scheduled_for: nil)

          job
        end
      rescue StandardError => e
        logger.error("An error occurred: #{e.message}. Backtrace: #{e.backtrace.join("\n")}")

        nil
      end
    end
  end
end
