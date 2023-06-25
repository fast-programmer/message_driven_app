require_relative '../app/models/messaging/message'
require_relative '../app/models/user_account'
require_relative '../app/models/user'
require_relative '../app/models/account'

Models::Messaging::Message::Try.delete_all
Models::Messaging::Message.delete_all
Models::Messaging::Queue.delete_all

Models::UserAccount.delete_all
Models::Account.delete_all
Models::User.delete_all

ActiveRecord::Base.connection.execute("SELECT setval('users_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('accounts_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('user_accounts_id_seq', 1, false)")

ActiveRecord::Base.connection.execute("SELECT setval('messaging_message_tries_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('messaging_messages_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('messaging_queues_id_seq', 1, false)")

sync_user_command = Messages::User.sync

1.times do |i|
  user = Models::User.create!(email: "user#{i+1}@fastprogrammer.co")
  account = Models::Account.create!(name: "Account #{i+1}", slug: "account-#{i+1}", owner_id: user.id)

  user.commands.create!(
    user_id: user.id,
    account_id: account.id,
    name: sync_user_command.name,
    body: sync_user_command.body,
    tries_max: 2)

  user.commands.create!(
    user_id: user.id,
    account_id: account.id,
    name: sync_user_command.name,
    body: sync_user_command.body,
    queue_until: Time.current + 10.seconds)
end
