require 'logger'
require 'colorize'

Signal.trap('INT') do
  Messages.shutdown

  exit
end

module Messaging
  module Messages
    @is_running = true

    def self.shutdown
      @is_running = false
    end

    def self.create_logger(output)
      color_scheme = {
        'DEBUG' => :cyan,
        'INFO' => :white,
        'WARN' => :yellow,
        'ERROR' => :red,
        'FATAL' => :red
      }
      thread_ids = Hash.new { |h, k| h[k] = h.size }

      logger = Logger.new(output)
      logger.formatter = proc do |severity, datetime, progname, msg|
        thread_id = thread_ids[Thread.current.object_id]
        color = color_scheme[severity] || :white
        "#{datetime.utc.iso8601(3)} TID-#{thread_id.to_s.rjust(3, '0')} #{progname}: [#{severity.downcase}]: #{msg}\n".colorize(color)
      end

      logger
    end

    def self.handle(queue_id:, handler:, poll:, concurrency:, current_time: Time.current)
      logger = create_logger(STDOUT)

      workers = Array.new(concurrency) do
        Thread.new do
          loop do
            message = shift(queue_id: queue_id, logger: logger, current_time: current_time)

            if message.nil?
              logger.info("No messages to handle")
              sleep poll
              next
            end

            success = false

            while !success
              begin
                handler.handle(message: message, logger: logger, queue_id: queue_id)
                message.update!(status: Models::Messaging::Message::STATUS[:handled])
                success = true
              rescue StandardError => e
                logger.error("Failed to handle message #{message.id}: #{e.message}")

                if message.retry_count < message.retry_limit
                  message.retry_count += 1
                  message.queued_until = calculate_queued_until(message.retry_count)
                  message.save

                  logger.info("Retry #{message.retry_count} scheduled for message #{message.id}.")
                else
                  logger.error("Exceeded retry limit for message #{message.id}. Marking as failed.")

                  message.update!(
                    status: Models::Messaging::Message::STATUS[:failed],
                    error_class_name: e.class.name,
                    error_message: e.message,
                    error_backtrace: e.backtrace
                  )
                end
              end
            end
          end
        end
      end

      workers.each { |worker| worker.join }
    end

    def self.calculate_queued_until(retry_count)
      backoff_time = sidekiq_like_backoff(retry_count)
      Time.current + backoff_time
    end

    def self.sidekiq_like_backoff(retry_count)
      (retry_count ** 4) + 15 + (rand(30) * (retry_count + 1))
    end

    def self.shift(queue_id:, logger:, current_time:)
      ActiveRecord::Base.transaction do
        message = Models::Message
                    .where(queue_id: queue_id)
                    .where(status: Models::Messaging::Message::STATUS[:unhandled])
                    .where('queued_until IS NULL OR queued_until < ?', current_time)
                    .order(created_at: :asc)
                    .limit(1)
                    .lock('FOR UPDATE SKIP LOCKED')
                    .first

        message&.update!(status: Models::Messaging::Message::STATUS[:handling])

        message
      end
    rescue ActiveRecord::ConnectionTimeoutError => e
      logger.warn("failed to find message in time > #{e.message}")

      nil
    end

    private_class_method :shift
  end
end
