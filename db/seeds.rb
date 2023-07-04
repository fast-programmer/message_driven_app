require_relative '../subdomains/iam'
require_relative '../subdomains/messaging'

Messaging::Models::HandlerMessage.destroy_all
Messaging::Models::Handler.destroy_all
Messaging::Models::Message.destroy_all
Messaging::Models::Queue.destroy_all

IAM::Models::UserAccount.destroy_all
IAM::Models::Account.destroy_all
IAM::Models::User.destroy_all

ActiveRecord::Base.connection.execute("SELECT setval('iam_users_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('iam_accounts_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('iam_user_accounts_id_seq', 1, false)")

ActiveRecord::Base.connection.execute("SELECT setval('messaging_handler_message_attempts_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('messaging_handler_messages_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('messaging_messages_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('messaging_handlers_id_seq', 1, false)")
ActiveRecord::Base.connection.execute("SELECT setval('messaging_queues_id_seq', 1, false)")

default_queue = Messaging::Models::Queue.default

handlers = [
  Messaging::Models::Handler.create!(
    queue_id: default_queue.id,
    slug: 'iam',
    name: 'IAM',
    class_name: 'IAM::Handler',
    method_name: 'handle',
    enabled: true),
  Messaging::Models::Handler.create!(
    queue_id: default_queue.id,
    slug: 'active-campaign-integration',
    name: 'Active Campaign Integration',
    class_name: 'ActiveCampaignIntegration::Handler',
    method_name: 'handle',
    enabled: true),
  Messaging::Models::Handler.create!(
    queue_id: default_queue.id,
    slug: 'mailchimp-integration',
    name: 'Mailchimp Integration',
    class_name: 'MailchimpIntegration::Handler',
    method_name: 'handle',
    enabled: true)
]

10.times do |i|
  user, event = IAM::User.create(email: "user#{i+1}@fastprogrammer.co")

  user, command = IAM::User.sync_async(
    account_id: event.account_id,
    user_id: event.user_id,
    id: user.id,
    queue_until: Time.current + 1.seconds,
    attempts_max: 2,
    priority: 10)
end
