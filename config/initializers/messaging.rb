Messaging.configure do |config|
  config.defaults.deep_merge!({
    job: {
      attempts: {
        max: 6,
        result: {
          persist: false
        },
        backoff: -> (current_time:, attempts_count:) do
          current_time + (attempt_count ** 4) + 15 + (rand(30) * (attempts_count))
        end
      }
    }
  })
end
