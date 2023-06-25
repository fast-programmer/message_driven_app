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

    def self.log_connection_pool_stats(logger:)
      stats = ActiveRecord::Base.connection_pool.stat

      logger.info "Size: #{stats[:size]}, Connections: #{stats[:connections]}, Busy: #{stats[:busy]}, Idle: #{stats[:idle]}, Waiting: #{stats[:waiting]}, CheckoutTimeout: #{stats[:checkout_timeout]}"
    end

    def self.handle(
          queue_id: Models::Messaging::Queue.default_id,
          handler:,
          poll:,
          concurrency:,
          current_time: Time.current)
      logger = create_logger(STDOUT)

      queue = Queue.new

      workers = concurrency.times.map do
        Thread.new do
          loop do
            message = queue.pop

            return_value = nil
            message.tries_count += 1
            started_at = Time.current

            begin
              ActiveRecord::Base.connection_pool.with_connection do
                return_value = handler.handle(message: message, logger: logger)
              end
            rescue StandardError => e
              ended_at = Time.current

              if message.tries_count < message.max_tries
                message.status = Models::Messaging::Message::STATUS[:unhandled]
                message.queue_until = calculate_queued_until(message.tries_count)
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

              next
            end

            ended_at = Time.current

            message.status = Models::Messaging::Message::STATUS[:handled]

            ActiveRecord::Base.transaction do
              message.save!

              message.tries.create!(
                index: message.tries_count, was_successful: true,
                started_at: started_at, ended_at: ended_at,
                return_value: return_value)
            end
          end
        end
      end

      loop do
        unless queue.length < concurrency
          logger.info('queue.length >= concurrency')

          sleep poll

          next
        end

        # log_connection_pool_stats(logger: logger)
        message = shift(queue_id: queue_id, logger: logger, current_time: current_time)
        # log_connection_pool_stats(logger: logger)

        unless message
          logger.info('no messages to handle')

          sleep poll

          next
        end

        queue.push(message)
      end

      workers.each { |worker| worker.join }
    end

    def self.calculate_queued_until(try_count)
      backoff_time = sidekiq_backoff(try_count)

      Time.current + backoff_time
    end

    def self.sidekiq_backoff(try_count)
      (retry_count ** 4) + 15 + (rand(30) * (try_count))
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
