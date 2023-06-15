require 'logger'
require 'colorize'

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

  def self.handle(handler:, poll:, concurrency:)
    logger = create_logger(STDOUT)

    workers = Array.new(concurrency) do
      Thread.new do
        loop do
          message = shift(logger: logger)

          if message.nil?
            logger.info("no messages to handle")

            sleep poll

            next
          end

          begin
            handler.handle(message: message, logger: logger)

            message.update!(status: Message::STATUS[:handled])
          rescue StandardError => e
            logger.error("failed to handle #{e.message} message #{message.id}")

            message.update!(status: Message::STATUS[:failed])
          end
        end
      end
    end

    workers.each { |worker| worker.join }
  end

  def self.shift(logger:)
    ActiveRecord::Base.transaction do
      message = Models::Message
                  .where(status: Message::STATUS[:unhandled])
                  .order(created_at: :asc)
                  .limit(1)
                  .lock('FOR UPDATE SKIP LOCKED')
                  .first

      message&.update!(status: Message::STATUS[:handling])

      message
    end
  rescue ActiveRecord::ConnectionTimeoutError => e
    logger.warn("failed to find message in time > #{e.message}")

    nil
  end

  private_class_method :shift
end
