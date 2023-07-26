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

      @processing = false
      @errors = []
      @queue = Queue.new
      @threads = [Thread.current]
      @thread_errors = []
      @thread_errors_mutex = Mutex.new

      Signal.trap('INT', method(:shutdown))
    end

    def process
      @processing = true

      @threads += @concurrency.times.map do |i|
        Thread.new do
          begin
            thread_index = i + 1

            ActiveRecord::Base.connection_pool.with_connection do
              while @processing
                job = @queue.pop

                attempt = Job.process(job: job, logger: logger)

                begin
                  ActiveRecord::Base.transaction do
                    job.save!

                    attempt.save!
                  end
                rescue StandardError => error
                  @logger.error("[Thread #{thread_index}] raised error ${error.message}")

                  if @processing
                    sleep poll

                    retry
                  else
                    raise error
                  end
                end
              end
            end

            $logger.info("[Thread #{thread_index}] terminating gracefully")
          rescue Exception => error
            @processing = false

            @errors_mutex.synchronize do
              @errors << [thread_index, error]
            end

            @logger.error("[Thread #{thread_index}] terminating due to unhandled error"
          end
        end
      end

      begin
        ActiveRecord::Base.connection_pool.with_connection do
          while @processing
            unless @queue.length < concurrency
              @logger.debug('@queue.length >= concurrency')

              sleep poll

              next
            end

            begin
              job = Job.dequeue(queue_id: @queue_id, logger: @logger)
            rescue StandardError => error
              @logger.error("[Thread 0] terminating due to unhandled error"

              if @processing
                sleep poll

                retry
              else
                raise error
              end
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
          @errors << [0, error]
        end

        $logger.error("[Thread 0] terminating due to unhandled error")
      end

      processor_threads.each(&:join)

      unless @errors.empty?
        @errors.each do |thread, error|
          @logger.error("[Thread #{thread_index}] terminated due to unhandled error: #{error.message}")
        end

        exit(1)
      end
    end

    def shutdown
      @processing = false
    end
  end
end
