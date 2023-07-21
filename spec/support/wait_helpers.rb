module WaitHelpers
  def attempt(max: 5, sleep: 1, &block)
    max.times do
      result = block.call
      return result if result
      sleep(sleep)
    end
    raise "Condition was not met within #{max * sleep} seconds"
  end
end
