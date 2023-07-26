def self.log_connection_pool_stats(logger:)
  stats = ActiveRecord::Base.connection_pool.stat

  log_hash = {
    Size: stats[:size],
    Connections: stats[:connections],
    Busy: stats[:busy],
    Idle: stats[:idle],
    Waiting: stats[:waiting],
    CheckoutTimeout: stats[:checkout_timeout]
  }

  log_message = log_hash.map { |k, v| "#{k}: #{v}" }.join(', ')

  logger.info log_message
end


# # /messaging/queues/default/messages/1

# Handler Messages

# * [IAM::Handler](/messaging/queues/default/handlers/iam)

#   => Attempt #1
#   => Attempt #2
#   => Attempt #3


# # /messaging/queues/default/handlers/iam?status=queued

# All (5), Unhandled (5), Handling (5), Handled (2), Delayed (10), Failed (0)

# => Unhandled Messages (5)

# * { id: 1, status, name, body } | [Details](messaging/queue/default/handler/iam/message/1)
# * { id: 2, status, name, body } | [Details](messaging/queue/default/handler/iam/message/2)
# * { id: 3, status, name, body } | [Details](messaging/queue/default/handler/iam/message/2)

# # /messaging/queue/default/handler/iam/message/1

# => Message 1

# => status
# => name
# => body

#   => Attempt #1
#   => Attempt #2
#   => Attempt #3

# | Retry | Delete


# # Note: as every return value and every error of every attempt is stored by default, this can add up to a lot of data
# # We recommend periodically deleting via scheduled tasks e.g.

# Messaging::Models::Job::Attempt.destroy_all




# /messaging/queues/default/messages/1/handlers/iam/unhandled


# /messaging/messages/1?queue=default&handler=iam&status=unhandled


# /messaging/messages/1?queue=default&handler=iam&status=unhandled


# /messaging/queue/default/handler/iam/messages/unhandled


# handler =>
# message =>

# messaging/handler-messages/1
#   handler =>
#   message =>


# <% handler_message.attempts.each do |attempt| %>
#             <div>
#   <p>Attempt ID: <%= attempt.id %></p>
#               <p>Started at: <%= attempt.started_at %></p>
#   <p>Ended at: <%= attempt.ended_at %></p>
#               <p>Successful: <%= attempt.successful %></p>
#   <p>Return value: <%= attempt.return_value %></p>
#               <p>Error class name: <%= attempt.error_class_name %></p>
#   <p>Error message: <%= attempt.error_message %></p>
#               <p>Error backtrace: <%= attempt.error_backtrace&.join("\n") %></p>
#   </div>
#           <% end %>



# how to get RSS
# ps -o rss= -p <pid>


# -> scheduled (handle_at > now, attempts_count = 0)
# -> rescheduled (handle_at > now, attempts_count >= 1, attempts_count < attempts_max)
# -> queued (handle_at = nil, attempts_count = 0)
# -> handling (handling_by, updated_at)
# -> handled (handling_by: nil, updated_at)
# -> failed (attempts_count == attempts_max)

# Jobs:

#   queued (5), handling (1), handled (151), failed (100)
# scheduled (14), rescheduled (50)

# queued (5), processing (1), processed (151), failed (100)
# scheduled (14), rescheduled (50)

Models::Job
  .where(queue_id: queue_id)
  .where(
    "(status = queued) || (status IN [:scheduled:, :rescheduled]) AND (handle_at <= :current_time)",
    queued: Models::Job::STATUS[:queued],
    scheduled: Models::Job::STATUS[:scheduled],
    rescheduled: Models::Job::STATUS[:scheduled],
    current_time: current_time)
  .order(priority: :desc, created_at: :asc)
  .limit(1)
  .lock('FOR UPDATE SKIP LOCKED')
  .first


scheduled or rescheduled same priority



# def create_jobs
#   ::Handler.delay.handle(message: self)
# end

# def create_jobs
#   Models::Handler.where(enabled: true).find_each do |handler|
#     klass = handler.class_name.constantize

#     if klass.respond_to?(:handles?) && klass.handles?(message: self)
#       scheduled_for = (klass.respond_to?(:scheduled_for) && klass.scheduled_for) || nil
#       priority = (klass.respond_to?(:priority) && klass.priority) || 0
#       attempts_max = (klass.respond_to?(:attempts_max) && klass.attempts_max) || 1

#       jobs.create!(
#         queue_id: handler.queue_id,
#         handler: handler.class_name.constantize,
#         status: scheduled_for ? Models::Job::STATUS[:scheduled] : Models::Job::STATUS[:queued],
#         priority: priority,
#         attempts_max: attempts_max)
#     end
#   end
# end


it "processes enqueued jobs" do
  job = attempt(max: 5, sleep: 1) do
    tested_event.reload

    tested_event.jobs&.last
  end

  expect(job.status.to eq(Models::Job::STATUS[:processed]))
end


# handler

module Handler
  extend self

  # def handle(message:, logger:)
  def handle(message:)
    # logger.info("[##{message.id}] Handler> message #{message.id} handling #{message.body.class.name}")



    # Messaging.config.defaults[:job][:queue_id]
    # Messaging.config.defaults[:job][:process_at].call(current_time: Time.current)
    # Messaging.config.defaults[:job][:attempts][:max]
    # Messaging.config.defaults[:job][:attempts][:backoff].call(
    #   current_time: Time.current, attempts_count: 1)

    debugger

    [
      IAM::Handler,
      ActiveCampaignIntegration::Handler,
      MailchimpIntegration::Handler
    ].each do |handler|
      message.jobs.create!(handler: handler)
    end


    # default_queue_id = Messaging::Models::Queue.default_id

    # [
    #   IAM::Handler,
    #   ActiveCampaignIntegration::Handler,
    #   MailchimpIntegration::Handler
    # ].each do |handler|
    #   queue_id = (handler.respond_to?(:queue_id) && handler.queue_id) || default_queue_id

    #   ActiveRecord::Base.transaction do
    #     message.jobs.create!(
    #       queue_id: queue_id,
    #       handler: handler,
    #       attempts_max: 2)
    #   end
    # end

    # logger.info("[##{message.id}] Handler> message #{message.id} handled #{message.body.class.name}")
  end

  def handles?(message:)
    true
  end
end

test_event = test.events.create!(skip_create_jobs: true)


# if you want to completely override publisher behaviour

ActiveRecord::Base.transaction do
  test = Models::Test.create!(account_id: 1, user_id: 2)
  test_event = test.events.create!(body: Messages::Test::Created.new(id: test.id))

  test_event.jobs.create!(handler: Handler.handle, attempts_max: 1)
end

# ActiveRecord::Base.transaction do
#   test = Models::Test.create!(account_id: 1, user_id: 2)
#   test_event = test.events.create!

#   test_event.jobs.create!(
#     handler: CustomHandler.handle,
#     options: { attempts_max: 2 })
# end


def destroy_recent
  Models::Job.where()
  job.destroy!
  => attempts
end

def destroy_recent_attempts
end


def handler=(handler)
  defaults = Models::Config.defaults.deep_merge(handler.defaults)

  self.queue_id = defaults[:job][:queue_id] if queue_id.nil?
  self.priority = options.priority if priority.nil?
  self.process_at = options.calculate_process_at if process_at.nil?

  self.handler_class_name = handler.name
  self.handler_method_name = handler.method_name
end

def handler
  handler_class_name.constantize.method(:handler_method_name)
end

def handler=(handler)
  self.handler_class_name = handler.name
  self.handler_method_name = handler.method_name

  options = self.options.merge(handler.options)

  # self.priority = options.priority
  # self.attempts_count = options.attempts
  # self.run_at = options.run_at
end

def handler
  handler_class_name.constantize
end



def process(poll: Config.defaults[:jobs][:poll],
            concurrency: Config.default[:jobs][:concurrency],
            queue_id: Config.defaults[:jobs][:queue_id],
            logger: Logger.create)


module Messaging
  module Jobs
    extend self

    @@is_processing = false

    def shutdown
      @@is_processing = false
    end

    Signal.trap('INT') do
      Message.shutdown

      exit
    end

    def process(poll: Config.jobs.poll,
                concurrency: Config.jobs.concurrency,
                queue_id: Config.jobs.queue_id,
                logger: Config.jobs.logger)
      queue = Queue.new

      @@is_processing = true

      processor_threads = concurrency.times.map do
        Thread.new do
          Thread.current.abort_on_exception = true

          ActiveRecord::Base.connection_pool.with_connection do
            while @@is_processing
              job = queue.pop

              Job.process(job: job, logger: logger)
            end
          end
        rescue StandardError => error
          logger.error("An error occurred: #{error.message}. Backtrace: #{error.backtrace.join("\n")}")

          sleep poll

          retry
        end
      end

      begin
        ActiveRecord::Base.connection_pool.with_connection do
          while @@is_processing
            unless queue.length < concurrency
              logger.debug('queue.length >= concurrency')

              sleep poll

              next
            end

            job = Job.dequeue(queue_id: queue_id, logger: logger)

            unless job
              logger.debug('no messages to handle')

              sleep poll

              next
            end

            queue.push(job)
          end
        end
      rescue StandardError => error
        logger.error("An error occurred: #{error.message}. Backtrace: #{error.backtrace.join("\n")}")

        sleep poll

        retry
      end

      processor_threads.each(&:join)
    end
  end
end


Thread.current.abort_on_exception = true




o
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

    def shutdown
      @processing = false
    end

    def process
      @processing = true

      Signal.trap('INT', method(:shutdown))

      processor_threads = concurrency.times.map do
        Thread.new do
          begin
            ActiveRecord::Base.connection_pool.with_connection do
              while @processing
                job = @queue.pop

                Job.process(job: job, logger: logger)
              end
            end
          rescue StandardError => error
            @logger.error("An error occurred: #{error.message}. Backtrace: #{error.backtrace.join("\n")}")

            sleep poll

            retry
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

            job = Job.dequeue(queue_id: queue_id, logger: logger)

            unless job
              @logger.debug('no messages to handle')

              sleep poll

              next
            end

            @queue.push(job)
          end
        end
      rescue StandardError => error
        @logger.error("An error occurred: #{error.message}. Backtrace: #{error.backtrace.join("\n")}")

        sleep poll

        retry
      end

      processor_threads.each(&:join)
    end
  end
end



def initialize(poll: Config.jobs.poll,
               concurrency: Config.jobs.concurrency,
               queue_id: Config.jobs.queue_id,
               logger: Config.jobs.logger)

  processor_threads = concurrency.times.map do
    Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        begin
          while @processing && !@error
            job = @queue.pop

            Job.process(job: job, logger: logger)
          end
        rescue => error
          @error = error

          logger.error("Exception occurred: #{error.class}: #{error.message}")
        end
      end
    end
  end



# )
#           end
#         end
#       end

#       begin
#         ActiveRecord::Base.connection_pool.with_connection do
#           while @processing
#             unless @queue.length < concurrency
#               @logger.debug('@queue.length >= concurrency')

#               sleep poll

#               next
#             end

#             job = Job.dequeue(queue_id: @queue_id, logger: @logger)

#             unless job
#               @logger.debug('no messages to handle')

#               sleep poll

#               next
#             end

#             @queue.push(job)
#           end
#         end
#       rescue Exception => error
#         @processing = false

#         @errors_mutex.synchronize do
#           @errors << [0, error]
#         end

#         $logger.error("[Thread 0] terminating due to unhandled error")
#       end

#       processor_threads.each(&:join)

#       unless @errors.empty?
#         @errors.each do |thread, error|
#           @logger.error("[Thread #{thread_index}] terminated due to unhandled error: #{error.message}")
#         end

#         exit(1)
#       end
#     end

#     def shutdown
#       @processing = false
#     end
#   end
# end


  # class Jobs
  #   def initialize(poll: 1,
  #                  concurrency: 5,
  #                  queue_id: 1,
  #                  logger: Logger.create)
  #     @poll = poll
  #     @concurrency = concurrency
  #     @queue_id = queue_id
  #     @logger = logger

  #     @processing = false
  #     @errors = []
  #     @queue = Queue.new
  #     @threads = [Thread.current]
  #     @thread_errors = []
  #     @thread_errors_mutex = Mutex.new

  #     Signal.trap('INT', method(:shutdown))
  #   end

  #   def process
  #     @processing = true

  #     @threads += @concurrency.times.map do |i|
  #       Thread.new do
  #         begin
  #           thread_index = i + 1

  #           ActiveRecord::Base.connection_pool.with_connection do
  #             while @processing
  #               job = @queue.pop

  #               job = Job.process(job: job, logger: logger)
  #             end
  #           end

  #           $logger.info("[Thread #{thread_index}] terminating gracefully")
  #         rescue Exception => error
  #           @processing = false

  #           @errors_mutex.synchronize do
  #             @errors << [thread_index, error]
  #           end

  #           @logger.error("[Thread #{thread_index}] terminating due to unhandled error")
