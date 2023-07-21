require_relative '../../config/environment'

Thread.new do
  ap Monitoring::Metrics.dump

  users = IAM::Models::User.first
  puts users.inspect

  ap Monitoring::Metrics.dump

  users = IAM::Models::User.last
  puts users.inspect
rescue StandardError => e
  puts "An error occurred: #{e.message}"
ensure
  ActiveRecord::Base.clear_active_connections!
end.join

puts "Finished"
