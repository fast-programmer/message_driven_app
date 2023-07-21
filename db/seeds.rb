require 'benchmark'

require_relative '../subdomains/iam'
require_relative '../subdomains/messaging'

# 1000.times do |i|
#   total_time = Benchmark.realtime do
#     Messaging::Models::Test.create!
#   end

#   puts "Messaging::Models::Test.create! (Total Time: #{total_time} seconds)"
# end


# total_time = Benchmark.realtime do
#   handlers = Messaging::Models::Handler.where(enabled: true).all
# end

# puts "Models::Handler.where(enabled: true); (Total Time: #{total_time} seconds)"
# debugger

# connection = ActiveRecord::Base.connection.raw_connection
# sql = "INSERT INTO messaging_tests DEFAULT VALUES;"

# 1000.times do |i|
#   total_time = Benchmark.realtime do
#     connection.exec(sql)
#   end

#   puts "INSERT INTO messaging_tests DEFAULT VALUES; (Total Time: #{total_time} seconds)"
# end

# 1000.times do |i|
#   total_time = Benchmark.realtime do
#     IAM::Workers::User::Sync.perform_async({ account_id: 1, user_id: i })
#   end

#   puts "IAM::Workers::User::Sync.perform_async (Total Time: #{total_time} seconds)"
# end

ActiveRecord::Base.connection_pool.with_connection do
  Messaging::Models::Test.delete_all
  Messaging::Models::Job::Attempt.delete_all
  Messaging::Models::Job.delete_all
  Messaging::Models::Handler.delete_all
  Messaging::Models::Message.delete_all
  Messaging::Models::Queue.delete_all

  IAM::Models::UserAccount.delete_all
  IAM::Models::Account.delete_all
  IAM::Models::User.delete_all

  ActiveRecord::Base.connection.execute("SELECT setval('iam_users_id_seq', 1, false)")
  ActiveRecord::Base.connection.execute("SELECT setval('iam_accounts_id_seq', 1, false)")
  ActiveRecord::Base.connection.execute("SELECT setval('iam_user_accounts_id_seq', 1, false)")

  ActiveRecord::Base.connection.execute("SELECT setval('messaging_job_attempts_id_seq', 1, false)")
  ActiveRecord::Base.connection.execute("SELECT setval('messaging_jobs_id_seq', 1, false)")
  ActiveRecord::Base.connection.execute("SELECT setval('messaging_messages_id_seq', 1, false)")
  ActiveRecord::Base.connection.execute("SELECT setval('messaging_handlers_id_seq', 1, false)")
  ActiveRecord::Base.connection.execute("SELECT setval('messaging_queues_id_seq', 1, false)")

  default_queue = Messaging::Models::Queue.default

  handlers = [
    Messaging::Models::Handler.create!(
      queue_id: default_queue.id,
      slug: 'app',
      name: 'App',
      class_name: 'Handler',
      enabled: true)
  ]

  # handlers = [
  #   Messaging::Models::Handler.create!(
  #     queue_id: default_queue.id,
  #     slug: 'iam',
  #     name: 'IAM',
  #     class_name: 'IAM::Handler',
  #     enabled: true),
  #   Messaging::Models::Handler.create!(
  #     queue_id: default_queue.id,
  #     slug: 'active-campaign-integration',
  #     name: 'Active Campaign Integration',
  #     class_name: 'ActiveCampaignIntegration::Handler',
  #     enabled: true),
  #   Messaging::Models::Handler.create!(
  #     queue_id: default_queue.id,
  #     slug: 'mailchimp-integration',
  #     name: 'Mailchimp Integration',
  #     class_name: 'MailchimpIntegration::Handler',
  #     enabled: true)
  # ]

  user, event = IAM::User.create(email: "user1@fastprogrammer.co")

  # job = event.jobs.create!(
  #   queue_id: Messaging::Models::Queue.default_id,
  #   handler: IAM::Handler)

  # 1000.times do |i|
  #   user = nil
  #   event = nil
  #   command = nil

  #   user, event = IAM::User.create(email: "user#{i+1}@fastprogrammer.co")

  #   user = IAM::Models::Account.find(event.account_id).users.find(user.id)

  #   body = IAM::Messages::User::Sync.new(user: { id: user.id })

  #   command = user.commands.new(
  #     account_id: event.account_id,
  #     user_id: user.id,
  #     body: body)

  #   # body_class_name = body.class.name
  #   # body_json = body.to_json.gsub("'", "''")

  #   total_time = Benchmark.realtime do
  #     command = user.commands.create!(
  #       account_id: event.account_id,
  #       user_id: user.id,
  #       body: body)

  #     # command.save!
  #     # command.save(validate: false)

  #     # ActiveRecord::Base.connection.execute <<-SQL
  #     #   INSERT INTO messaging_messages
  #     #   (queue_id, account_id, user_id, type, body_class_name, body_json, messageable_type, messageable_id, created_at, updated_at, priority, attempts_max)
  #     #   VALUES (#{1}, #{event.account_id}, #{user.id}, '#{Messaging::Models::Command}', '#{body_class_name}', '#{body_json}', '#{user.class.name}', #{user.id}, '#{Time.now.utc}', '#{Time.now.utc}', #{0}, #{1})
  #     # SQL
  #   end

  #   puts "db/seeds.rb> user.commands.create! (Total Time: #{total_time} seconds)"
  # end

  # 1000.times do |i|
  #   user = nil
  #   event = nil
  #   command = nil

  #   total_time = Benchmark.realtime do
  #     user, event = IAM::User.create(email: "user#{i+1}@fastprogrammer.co")
  #   end

  #   # puts "[#{i}] IAM::User.create (Total Time: #{total_time} seconds)"

  #   total_time = Benchmark.realtime do
  #     user, command = IAM::User.sync_async(
  #       account_id: event.account_id,
  #       user_id: event.user_id,
  #       id: user.id,
  #       attempts_max: 1)
  #   end

  #   puts "[#{i}] IAM::User.sync_async (Total Time: #{total_time} seconds)"
  # end

  # user, command = IAM::User.sync_async(
  #   account_id: event.account_id,
  #   user_id: event.user_id,
  #   id: user.id,
  #   scheduled_for: Time.current + 5.seconds,
  #   attempts_max: 5,
  #   priority: 10)
end

# command = user.commands.create!(
#   account_id: account_id,
#   user_id: user_id,
#   body: Messages::User::Sync.new(user: { id: id }),
#   skip_create_jobs: true)


# command = user.commands.create!(
#   body: Messages::User::Sync.new(
#     user: { id: id }))

# job = command.jobs.create!(
#   handler: IAM::Handler,
#   scheduled_for: Time.current + 5.seconds,
#   attempts_max: 0)

# job = command.jobs.create!(handler: IAM::Handler)
# job = command.jobs.create!(handler: ActiveCampaignIntegration::Handler)
# job = command.jobs.create!(handler: MailCampaign::Handler)

# jobs
#   queued
#   scheduled (incl rescheduled)
#   processing
#   processed
#   failed

# queued
# SELECT * FROM messaging_jobs
# WHERE status = 'queued'

# scheduled
# SELECT * FROM messaging_jobs
# WHERE status = 'scheduled'
# AND scheduled_for <= Time.now

# rescheduled
# SELECT * FROM messaging_jobs
# WHERE status = 'scheduled'
# AND schedule_for <= Time.now
# AND attempts_count >= 1

# procsesing
# SELECT * FROM messaging_jobs
# WHERE status = 'processing'

# processed
# SELECT * FROM messaging_jobs
# WHERE status = 'processed'

# failed
# SELECT * FROM messaging_jobs
# WHERE status = 'failed'

# # status: queued, queue_until <= Time.now

#   when StripeIntegration::Payout::Completed
#   Core::User.updated(account: account, user: user)
# end


# account.messages.last.jobs

# Stripe Integration
#   Account 1
#     Created
#       Jobs
#         1. Handler - Handled
#         2. IAM::Handler - Handled
#             attempts: [{ successful: true, return_value: nil }],
#         3. MailCampaignIntegration::Handler - Failed
#             attempts: [{ successful: false, error... }],

