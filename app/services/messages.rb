require 'logger'
require 'colorize'
require 'concurrent-ruby'

Signal.trap('INT') do
  Messages.shutdown

  exit
end

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

  # def self.handle(handler:, poll_interval: 1, concurrency: 5)
  #   stdout_logger = create_logger(STDOUT)
  #   stderr_logger = create_logger(STDERR)

  #   executor = Concurrent::ThreadPoolExecutor.new(
  #     min_threads: 0,
  #     max_threads: 5,
  #     max_queue: 0,
  #     idletime: 1,
  #     fallback_policy: :abort
  #   )

  #   active_handler_count = Concurrent::AtomicFixnum.new(0)

  #   while @is_running do
  #     puts "executor.queue_length: #{executor.queue_length}"

  #     if active_handler_count.value == concurrency
  #       stdout_logger.info('No capacity remaining, sleeping...')
  #       sleep poll_interval
  #       next
  #     end

  #     stdout_logger.info("Capacity remains for #{concurrency - active_handler_count.value} messages")
  #     messages = slice(0, concurrency - active_handler_count.value)

  #     if messages.empty?
  #       stdout_logger.info('No messages found, sleeping...')

  #       sleep poll_interval
  #       next
  #     end

  #     stdout_logger.info("#{messages.length} messages found, continuing...")

  #     messages.each do |message|
  #       active_handler_count.increment

  #       executor.post do
  #         ActiveRecord::Base.connection_pool.with_connection do
  #           begin
  #             handler.handle(
  #               message: message,
  #               stdout_logger: stdout_logger,
  #               stderr_logger: stderr_logger
  #             )

  #             message.update!(status: Message::STATUS[:handled])
  #           rescue StandardError => e
  #             stdout_logger.error("An error occurred while handling message #{message.id}: #{e.message}...")
  #             stderr_logger.error("An error occurred while handling message #{message.id}: #{e.message}...")

  #             message.update!(status: Message::STATUS[:failed])
  #           end
  #         end
  #       end

  #       active_handler_count.decrement
  #     end
  #   end

  #   executor.shutdown
  #   executor.wait_for_termination
  # rescue StandardError => e
  #   debugger
  # end
  def self.handle(handler:, poll_interval: 1, concurrency: 5)
    threads = []

    while @is_running do
      while threads.count { |t| t.status == "run" } >= concurrency
        sleep poll_interval
      end

      messages = slice(0, concurrency - threads.count { |t| t.status == "run" })

      if messages.empty?
        sleep poll_interval
        next
      end

      messages.each do |message|
        threads << Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            begin
              handler.handle(message: message)

              message.update!(status: Message::STATUS[:handled])
            rescue StandardError => e
              # Log the error
              message.update!(status: Message::STATUS[:failed])
            end
          end
        end
      end

      # Clean up any threads that have finished
      threads.reject! { |t| !t.status }
    end

    # Wait for any remaining threads to finish
    threads.each(&:join)
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
