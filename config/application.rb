require_relative 'boot'

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative '../app/models/application_record'
require_relative '../app/models/user'
require_relative '../app/models/message'
require_relative '../app/models/event'
require_relative '../app/models/command'

require_relative '../app/services/user'
require_relative '../app/services/message'

module MessageDrivenApp
  class Application < Rails::Application
    config.load_defaults 6.0

    config.generators.system_tests = nil
  end
end
