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

10.times do |i|
  ActiveRecord::Base.transaction do
    user = Models::User.create!(email: "user#{i+1}@fastprogrammer.co")

    user.events.create!(
      user_id: user.id,
      body: Messages::User::Created.new(email: user.email))

    account = Models::Account.create!(
      name: "Account #{i+1}", slug: "account-#{i+1}", owner_id: user.id)

    account.events.create!(
      account_id: account.id,
      user_id: user.id,
      body: Messages::Account::Created.new(
        name: account.name,
        slug: account.slug,
        owner_id: account.owner_id))

    user.commands.create!(
      account_id: account.id,
      user_id: user.id,
      body: Messages::User::Sync.new,
      attempts_max: 2)

    user.commands.create!(
      account_id: account.id,
      user_id: user.id,
      body: Messages::User::Sync.new,
      queue_until: Time.current + 10.seconds)
  end
end
