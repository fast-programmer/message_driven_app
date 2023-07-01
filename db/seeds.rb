require_relative '../app/models/messaging/message'
require_relative '../app/models/iam/user_account'
require_relative '../app/models/iam/user'
require_relative '../app/models/iam/account'

require_relative '../app/messages/iam/user_pb'
require_relative '../app/messages/iam/account_pb'

Models::Messaging::Message.destroy_all
# Models::Messaging::Message::Attempt.delete_all
Models::Messaging::Queue.delete_all

Models::IAM::UserAccount.delete_all
Models::IAM::Account.delete_all
Models::IAM::User.delete_all

ActiveRecord::Base.connection.execute("SELECT setval('iam_users_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('iam_accounts_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('iam_user_accounts_id_seq', 1, false)")

ActiveRecord::Base.connection.execute("SELECT setval('messaging_message_attempts_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('messaging_messages_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('messaging_queues_id_seq', 1, false)")

1.times do |i|
  user, event = IAM::User.create(email: "user#{i+1}@fastprogrammer.co")

  user, command = IAM::User.sync_async(
    account_id: event.account_id,
    user_id: event.user_id,
    id: user.id,
    queue_until: Time.current + 1.seconds,
    attempts_max: 2)
end
