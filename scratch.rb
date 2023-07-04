def self.log_connection_pool_stats(logger:)
  stats = ActiveRecord::Base.connection_pool.stat

  log_hash = {
    Size: stats[:size],
    Connections: stats[:connections],
    Busy: stats[:busy],
    Idle: stats[:idle],
    Waiting: stats[:waiting],
    CheckoutTimeout: stats[:checkout_timeout]
  }

  log_message = log_hash.map { |k, v| "#{k}: #{v}" }.join(', ')

  logger.info log_message
end
