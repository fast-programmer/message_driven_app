require_relative 'boot'

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"

Bundler.require(*Rails.groups)

require_relative '../app/models/application_record'

require_relative '../subdomains/monitoring'
require_relative '../subdomains/iam'
require_relative '../subdomains/messaging'
require_relative '../subdomains/active_campaign_integration'
require_relative '../subdomains/mailchimp_integration'

module MessageDrivenApp
  class Application < Rails::Application
    config.load_defaults 6.0

    config.generators.system_tests = nil
  end
end
