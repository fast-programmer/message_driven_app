require_relative 'boot'

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"

Bundler.require(*Rails.groups)

require_relative '../app/models/application_record'

require_relative '../app/models/iam/user'
require_relative '../app/models/iam/account'
require_relative '../app/models/iam/user_account'

require_relative '../app/models/messaging/queue'
require_relative '../app/models/messaging/message'
require_relative '../app/models/messaging/event'
require_relative '../app/models/messaging/command'

require_relative '../app/messages/iam/user_pb'
require_relative '../app/messages/iam/account_pb'

require_relative '../app/services/iam/user'

require_relative '../app/services/messaging/logger'
require_relative '../app/services/messaging/message'

require_relative '../subdomains/iam'
require_relative '../subdomains/active_campaign_integration'
require_relative '../subdomains/mailchimp_integration'

require_relative '../app/handlers/handler'

module MessageDrivenApp
  class Application < Rails::Application
    config.load_defaults 6.0

    config.generators.system_tests = nil
  end
end
