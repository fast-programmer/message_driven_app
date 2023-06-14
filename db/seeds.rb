require_relative '../subdomains/iam/services/user'

(1..6).each do |number|
  IAM::User.create(email: "user#{number}@fastprogrammer.co")
end
