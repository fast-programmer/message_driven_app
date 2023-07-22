require_relative 'messaging/models/config'
require_relative 'messaging/models/queue'
require_relative 'messaging/models/publisher'
require_relative 'messaging/models/message'
require_relative 'messaging/models/job'
require_relative 'messaging/models/event'
require_relative 'messaging/models/command'
require_relative 'messaging/models/test'

require_relative 'messaging/services/logger'
require_relative 'messaging/services/job'
require_relative 'messaging/services/jobs'

module Messaging
  class << self
    attr_accessor :config
  end

  def self.configure
    self.config ||= Models::Config.new

    yield(config)
  end
end
