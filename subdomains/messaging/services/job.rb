module Messaging
  module Job
    extend self

    def dequeue(queue_id:, logger:,
                current_time: Time.current)
      ActiveRecord::Base.transaction do
        Models::Job
          .where(queue_id: queue_id)
          .where(
            "(status = :queued OR (status IN (:scheduled, :rescheduled) AND process_at <= :current_time))",
            queued: Models::Job::STATUS[:queued],
            scheduled: Models::Job::STATUS[:scheduled],
            rescheduled: Models::Job::STATUS[:rescheduled],
            current_time: current_time)
          .order(priority: :desc, created_at: :asc)
          .limit(1)
          .lock('FOR UPDATE SKIP LOCKED')
          .first

        job&.update!(
          status: Models::Job::STATUS[:processing],
          process_at: nil)

        job
      end
    end

    def process(job:, logger:, running:, poll:)
      successful = nil
      started_at = nil
      ended_at = nil
      result = nil
      error = nil

      begin
        started_at = Time.current

        result = job.handler_class_name.constantize.send(
          job.handler_method_name, message: job.message, logger: logger)

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
          result: result)
      else
        failed(
          job: job,
          started_at: started_at,
          ended_at: ended_at,
          error: error)
      end
    end

    def processed(job:, started_at:, ended_at:, result:)
      job.attempts_count += 1
      job.status = Models::Job::STATUS[:processed]
      job.process_at = nil

      ActiveRecord::Base.transaction do
        job.save!

        job.attempts.create!(
          index: job.attempts_count,
          successful: true,
          started_at: started_at,
          ended_at: ended_at,
          result: result)
      end

      job
    end

    def failed(job:, started_at:, ended_at:, error:)
      job.attempts_count += 1

      attempt = job.attempts.new(
        index: job.attempts_count,
        successful: false,
        started_at: started_at,
        ended_at: ended_at,
        error_class_name: error.class.name,
        error_message: error.message,
        error_backtrace: error.backtrace)

      if job.attempts_count < job.attempts_max
        job.status = Models::Job::STATUS[:rescheduled]

        job_defaults = Config.defaults[:job].merge(job.handler.constantize.defaults)

        job.process_at = job_defaults.attempts.backoff.call(
          current_time: Time.current, attempt: attempt)
      else
        job.status = Models::Job::STATUS[:failed]
        job.process_at = nil
      end

      ActiveRecord::Base.transaction do
        job.save!

        attempt.save!
      end

      job
    end
  end
end
