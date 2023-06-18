require 'logger'
require 'colorize'

module Messaging
  Signal.trap('INT') do

    Message.shutdown

    exit
  end

  module Message
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

    def self.handle(
          queue_id: Models::Messaging::Queue.default_id,
          handler:,
          poll:,
          concurrency:,
          current_time: Time.current)
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

            begin
              handler.handle(message: message, logger: logger)
            rescue StandardError => e
              logger.error("Failed to handle message #{message.id}: #{e.message}")

              ActiveRecord::Base.transaction do
                message.messaging_errors.create!(
                  attempt: message.messaging_errors.maximum(:attempt) || 1,
                  class_name: e.class.name,
                  message_text: e.message,
                  backtrace: e.backtrace
                )

                max_retry_attempt = message.retries.maximum(:attempt) || 0

                if max_retry_attempt < message.retry_limit
                  next_retry_attempt = max_retry_attempt + 1
                  logger.info("Retrying attempt #{next_retry_attempt} for scheduled for message #{message.id}.")

                  next_queued_until = calculate_queued_until(next_retry_attempt)

                  message.update!(status: Models::Messaging::Message::STATUS[:unhandled], queued_until: next_queued_until)
                  message.retries.create!(attempt: next_retry_attempt)
                else
                  logger.error("Exceeded retry limit for message #{message.id}. Marking as failed.")
                  message.update!(status: Models::Messaging::Message::STATUS[:failed])
                end
              end

              next
            end

            message.update!(status: Models::Messaging::Message::STATUS[:handled])
          end
        end
      end

      workers.each { |worker| worker.join }
    end

    def self.calculate_queued_until(retry_count)
      backoff_time = sidekiq_backoff(retry_count)

      Time.current + backoff_time
    end

    def self.sidekiq_backoff(retry_count)
      (retry_count ** 4) + 15 + (rand(30) * (retry_count + 1))
    end

    def self.shift(queue_id:, logger:, current_time:)
      ActiveRecord::Base.transaction do
        message = Models::Messaging::Message
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
