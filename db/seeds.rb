require_relative '../app/models/messaging/message'
require_relative '../app/models/user_account'
require_relative '../app/models/user'
require_relative '../app/models/account'

require_relative '../app/messages/user_pb'
require_relative '../app/messages/account_pb'

Models::Messaging::Message.destroy_all
# Models::Messaging::Message::Attempt.delete_all
Models::Messaging::Queue.delete_all

Models::UserAccount.delete_all
Models::Account.delete_all
Models::User.delete_all

ActiveRecord::Base.connection.execute("SELECT setval('users_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('accounts_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('user_accounts_id_seq', 1, false)")

ActiveRecord::Base.connection.execute("SELECT setval('messaging_message_attempts_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('messaging_messages_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('messaging_queues_id_seq', 1, false)")

1.times do |i|
  user, event = User.create(email: "user#{i+1}@fastprogrammer.co")

  user, command = User.sync_async(
    account_id: event.account_id,
    user_id: user.id,
    id: user.id,
    queue_until: Time.current + 1.seconds,
    attempts_max: 2)
end
