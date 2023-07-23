module Messaging
  class Jobs
    def initialize(poll: 1,
                   concurrency: 5,
                   queue_id: 1,
                   logger: Logger.create)
      @poll = poll
      @concurrency = concurrency
      @queue_id = queue_id
      @logger = logger

      @errors = []
      @queue = Queue.new
      @processing = false
      @thread_errors_mutex = Mutex.new

      Signal.trap('INT', method(:shutdown))
    end

    def process
      @processing = true

      processor_threads = @concurrency.times.map do |i|
        Thread.new do
          begin
            thread_index = i + 1

            ActiveRecord::Base.connection_pool.with_connection do
              while @processing
                job = @queue.pop

                begin
                  Job.process(job: job, logger: logger)
                rescue StandardError => error
                  @logger.error("An error occurred: #{error.message}. Backtrace: #{error.backtrace.join("\n")}")
                end
              end
            end

            @logger.info("Thread #{thread_index} has been terminated gracefully")
          rescue Exception => error
            @processing = false

            @errors_mutex.synchronize do
              @errors << [Thread.current, error]
            end

            @logger.error("Thread #{thread_index} has been terminated due to an unhandled error")
          end
        end
      end

      begin
        ActiveRecord::Base.connection_pool.with_connection do
          while @processing
            job = nil

            unless @queue.length < concurrency
              @logger.debug('@queue.length >= concurrency')

              sleep poll

              next
            end

            begin
              job = Job.dequeue(queue_id: @queue_id, logger: @logger)
            rescue StandardError => error
              @logger.error("An error occurred: #{error.message}. Backtrace: #{error.backtrace.join("\n")}")

              sleep poll

              retry
            end

            unless job
              @logger.debug('no messages to handle')

              sleep poll

              next
            end

            @queue.push(job)
          end
        end
      rescue Exception => error
        @processing = false

        @errors_mutex.synchronize do
          @errors << [Thread.current, error]
        end

        @logger.error("Main thread #{Thread.current.object_id} has been terminated due to an unhandled error")
      end

      processor_threads.each(&:join)

      unless @errors.empty?
        @errors.each do |thread, error|
          @logger.error("Thread was terminated due to an unhandled error: #{error.message}")
        end

        exit(1)
      end
    end

    def shutdown
      @processing = false
    end
  end
end
