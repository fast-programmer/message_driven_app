require_relative '../app/models/messaging/retry'
require_relative '../app/models/messaging/error'
require_relative '../app/models/messaging/message'
require_relative '../app/models/user_account'
require_relative '../app/models/user'
require_relative '../app/models/account'

Models::Messaging::Retry.delete_all
Models::Messaging::Error.delete_all
Models::Messaging::Message.delete_all
Models::Messaging::Queue.delete_all

Models::UserAccount.delete_all
Models::Account.delete_all
Models::User.delete_all

ActiveRecord::Base.connection.execute("SELECT setval('users_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('accounts_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('user_accounts_id_seq', 1, false)")

ActiveRecord::Base.connection.execute("SELECT setval('messaging_errors_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('messaging_messages_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('messaging_queues_id_seq', 1, false)")

user = Models::User.create!(email: "user1@fastprogrammer.co")
account = Models::Account.create!(name: "Account 1", slug: "account-1", owner_id: user.id)
sync_user_command = Messages::User.sync

user.commands.create!(
  user_id: user.id,
  account_id: account.id,
  name: sync_user_command.name,
  body: sync_user_command.body,
  queue_until: Time.current + 10.seconds
)

user.commands.create!(
  user_id: user.id,
  name: sync_user_command.name,
  body: sync_user_command.body,
  queue_until: Time.current + 10.seconds
)

# queued
# requeued
# rehandling
# handled
# failed

command = user.commands.create!(
  user_id: user.id,
  name: sync_user_command.name,
  body: sync_user_command.body,
  queue_until: Time.current + 10.seconds,
  max_attempts: 2
)

command.attempts.last

command.status => 'failed'
last_attempt = command.attempts.last
last_attempt.error

command.status => 'queued'
command.attempts_count => 0
command.max_attempts => 1
command.attempts => []

command.status => 'queued'
command.attempt => 1
command.attempts => [{ index: 1, error: nil }]

command.error => command.attempts[0].error

if command.attempts_count < command.attempts.max_attempts
  command.attempts.create!(started_at:, ended_at:, error:)
end

command.status => 'handled'
command.attempts => 1
command.max_attempts => 1
command.attempts[0].error => nil

command.status => 'failed'
command.attempts => 1
command.max_attempts => 1
command.attempts[0].error => nil






command.status => 'unhandled'
command.attempts => 1
command.max_attempts => 2
command.attempts[0].error => { 1 }

attempts





command.status => 'failed'
command.attempts => 1
command.max_attempts => 1
command.attempts[0].error => nil


command.retry => 1
command.retry_count => 0
command.retries => []
command.error => nil

command.status => 'queued'
command.attempt => 1
command.retry => 1
command.retry_count => 0
command.retries => []
command.error => { ... }


commands.status => 'requeued'
commands.retry => 1
commands.retry_count => 0
commands.retries => []
commands.error => { ... }

commands.status => 'handling'
commands.retry => 1
commands.retry_count => 0
commands.retries => []
commands.error => { ... }

commands.status => 'handled'
commands.retry => 1
commands.retry_count => 1
commands.retries.first

commands.status => 'failed'
commands.retry => 1
commands.retry_count => 1

# message.status => 'requeued'
# message.last_error => retry_count > 0 ? retries.last.error : message.error
# message.retry: 1
# message.retry_count => 0
# message.retries.last.index => 0
# message.retries.last.error
# message.retry_queue: 'default'
# message.dead_queue: 'default'

# retry_attempt_limit: 3

# (1..2).each do |number|
#   user = User.create(email: "user#{number}@fastprogrammer.co")
#   account = Account.create(name: "Account #{number}", slug: "account-#{number}", owner_id: user.id)

#   User.sync_async(account_id: account.id, user_id: user.id, id: user.id)
# end
