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
