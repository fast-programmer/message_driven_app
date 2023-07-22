module Messaging
  class Jobs
    def initialize(poll: Config.jobs.poll,
                   concurrency: Config.jobs.concurrency,
                   queue_id: Config.jobs.queue_id,
                   logger: Config.jobs.logger)
      @poll = poll
      @concurrency = concurrency
      @queue_id = queue_id
      @logger = logger

      @processing = false
      @queue = Queue.new
    end

    def process
      @processing = true

      Signal.trap('INT', method(:shutdown))

      processor_threads = concurrency.times.map do
        Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            while @processing
              job = @queue.pop

              Job.process(job: job, logger: logger)
            end
          end
        end
      end

      ActiveRecord::Base.connection_pool.with_connection do
        while @processing
          unless @queue.length < concurrency
            @logger.debug('@queue.length >= concurrency')

            sleep poll

            next
          end

          job = Job.dequeue(queue_id: queue_id, logger: logger)

          unless job
            @logger.debug('no messages to handle')

            sleep poll

            next
          end

          @queue.push(job)
        end
      end

      processor_threads.each(&:join)
    end

    def shutdown
      @processing = false
    end
  end
end
