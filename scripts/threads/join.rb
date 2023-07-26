require 'logger'

$threads = []
$errors = []
$logger = Logger.new(STDOUT)
$running = true

Signal.trap("INT") { $running = false }

def spawn_threads(count)
  count.times do |i|
    $threads << Thread.current

    $threads << Thread.new do
      begin
        thread_index = i + 1

        while $running
          $logger.info("[Thread #{thread_index}] running")

          if [2, 3].include?(thread_index)
            sleep(3)

            raise StandardError, 'Random Exception'
          end

          sleep 1
        end

        $logger.info("[Thread #{thread_index}] terminating gracefully")
      rescue Exception => error
        $running = false
        $errors << [thread_index, error]
        $logger.error("[Thread #{thread_index}] terminating due to unhandled error")
      end
    end
  end
end

begin
  spawn_threads(5)

  while $running
    $logger.info("[Thread 0] running")

    sleep 1

    # raise StandardError, "An unhandled error occurred in main thread"
  end
rescue Exception => error
  $running = false
  $errors << [0, error]
  $logger.error("[Thread 0] terminating due to unhandled error")
end

$threads.each do |thread|
  $logger.info("[Thread 0] joining thread #{thread.object_id}")
  thread.join
  $logger.info("[Thread 0] joined thread #{thread.object_id}")
end

unless $errors.empty?
  $errors.each do |thread_error|
    thread_index, error = thread_error

    $logger.error("[Thread #{thread_index}] terminated due to unhandled error: #{error.message}")
  end

  exit(1)
end
