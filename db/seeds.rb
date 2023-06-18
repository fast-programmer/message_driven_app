require_relative '../app/models/messaging/message'
require_relative '../app/models/user_account'
require_relative '../app/models/user'
require_relative '../app/models/account'

Models::Messaging::Message.delete_all
Models::Messaging::Queue.delete_all

Models::UserAccount.delete_all
Models::Account.delete_all
Models::User.delete_all

ActiveRecord::Base.connection.execute("SELECT setval('users_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('messaging_queues_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('messaging_messages_id_seq', 1, false)")

(1..2).each do |number|
  user = User.create(email: "user#{number}@fastprogrammer.co")
  account = Account.create(name: "Account #{number}", slug: "account-#{number}", owner_id: user.id)

  User.sync_async(account_id: account.id, user_id: user.id, id: user.id)
end
