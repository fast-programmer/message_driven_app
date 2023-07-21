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
# -> queued (handle_at = nil, attempts_count = 0)
# -> handling (handling_by, updated_at)
# -> handled (handling_by: nil, updated_at)
# -> rescheduled (handle_at > now, attempts_count >= 1, attempts_count < attempts_max)
# -> failed (attempts_count == attempts_max)

# Jobs:

#   queued (5), handling (1), handled (151), failed (100)
# scheduled (14), rescheduled (50)

# queued (5), processing (1), processed (151), failed (100)
# scheduled (14), rescheduled (50)


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
