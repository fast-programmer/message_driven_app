require_relative '../app/models/message'
require_relative '../subdomains/iam/models/user'

require_relative '../subdomains/iam/services/user'

Models::Message.delete_all
IAM::Models::User.delete_all

ActiveRecord::Base.connection.execute("SELECT setval('messages_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('users_id_seq', 1, false)")

(1..10).each do |number|
  user = IAM::User.create(email: "user#{number}@fastprogrammer.co")
  IAM::User.sync_async(user_id: user.id, id: user.id)
end
