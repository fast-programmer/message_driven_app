require_relative 'boot'

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"

Bundler.require(*Rails.groups)

require_relative '../app/models/application_record'
require_relative '../app/models/message'
require_relative '../app/models/event'
require_relative '../app/models/command'

require_relative '../app/services/message'

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
