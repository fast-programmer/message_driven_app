require 'logger'
require 'colorize'

module Messaging
  module Logger
    def self.create(output = $stdout)
      color_scheme = {
        'DEBUG' => :cyan,
        'INFO' => :white,
        'WARN' => :yellow,
        'ERROR' => :red,
        'FATAL' => :red
      }
      thread_ids = Hash.new { |h, k| h[k] = h.size }

      logger = ::Logger.new(output)
      logger.formatter = proc do |severity, datetime, progname, msg|
        thread_id = thread_ids[Thread.current.object_id]
        color = color_scheme[severity] || :white
        "#{datetime.utc.iso8601(3)} TID-#{thread_id.to_s.rjust(3, '0')} #{progname}: [#{severity.downcase}]: #{msg}\n".colorize(color)
      end
      logger
    end
  end
end
