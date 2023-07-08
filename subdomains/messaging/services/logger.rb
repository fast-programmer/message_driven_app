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

      logger = ::Logger.new(output)
      logger.formatter = proc do |severity, datetime, progname, msg|
        thread_id = "tid=#{Thread.current.object_id.to_s(16)}"
        pid = "pid=#{Process.pid}"
        color = color_scheme[severity] || :white

        "#{datetime.utc.iso8601(3)}Z #{pid} #{thread_id} #{severity}: #{msg}\n".colorize(color)
      end
      logger
    end
  end
end
