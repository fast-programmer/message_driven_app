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

  def self.handle(handler:, poll_interval: 1, concurrency: 5)
    stdout_logger = create_logger(STDOUT)
    stderr_logger = create_logger(STDERR)

    executor = Concurrent::ThreadPoolExecutor.new(
      min_threads: 0,
      max_threads: 5,
      max_queue: 1,
      idletime: 1,
      fallback_policy: :abort
    )

    active_thread_count = Concurrent::AtomicFixnum.new(0)

    while @is_running do
      remaining_capacity = concurrency - executor.length - executor.queue_length

      (1..5).each do |number|
        executor.post do
          stdout_logger.info("#{number} executor.post finished")
        end
      end

      sleep(10)
      debugger

      executor.post do
        stdout_logger.info("additional executor.post started #{remaining_capacity}")
        sleep(10)
        stdout_logger.info("additional executor.post finished #{remaining_capacity}")
      end

      sleep(2)
      debugger

      sleep(2)

      if remaining_capacity <= 0
        stdout_logger.info('No capacity remaining, sleeping...')
        sleep poll_interval
        next
      end

      messages = slice(0, remaining_capacity)

      if messages.empty?
        stdout_logger.info('No messages found, sleeping...')

        sleep poll_interval
        next
      end

      stdout_logger.info("#{messages.length} messages found, continuing...")

      messages.each do |message|
        executor.post do
          # ActiveRecord::Base.connection_pool.with_connection do
            begin
              active_thread_count.increment

              handler.handle(
                message: message,
                stdout_logger: stdout_logger,
                stderr_logger: stderr_logger
              )

              message.update!(status: Message::STATUS[:handled])
            rescue StandardError => e
              stdout_logger.error("An error occurred while handling message #{message.id}: #{e.message}...")
              stderr_logger.error("An error occurred while handling message #{message.id}: #{e.message}...")

              message.update!(status: Message::STATUS[:failed])
            ensure
              active_thread_count.decrement
            end
          # end
        end
      end
    end

    executor.shutdown
    executor.wait_for_termination
  rescue StandardError => e
    debugger
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
