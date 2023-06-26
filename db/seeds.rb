require_relative '../app/models/messaging/message'
require_relative '../app/models/user_account'
require_relative '../app/models/user'
require_relative '../app/models/account'

require_relative '../app/messages/user'
require_relative '../app/messages/account'

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

10.times do |i|
  user = Models::User.create!(email: "user#{i+1}@fastprogrammer.co")
  user.messages << Messages::User.created(user_id: user.id, email: user.email)

  account = Models::Account.create!(name: "Account #{i+1}", slug: "account-#{i+1}", owner_id: user.id)
  account.messages << Messages::Account.created(account_id: account.id, user_id: user.id, name: account.name, slug: account.slug, owner_id: account.owner_id)

  user.messages << Messages::User.sync(account_id: account.id, user_id: user.id, tries_max: 2)
  user.messages << Messages::User.sync(account_id: account.id, user_id: user.id, queue_until: Time.current + 10.seconds)
end
