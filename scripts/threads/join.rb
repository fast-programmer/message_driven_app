require 'logger'

$threads = []
$errors = []
$logger = Logger.new(STDOUT)
$running = true

Signal.trap("INT") { $running = false }

def spawn_threads(count)
  count.times do |i|
    $threads << Thread.new do
      begin
        thread_index = i + 1

        while $running
          $logger.info("[Thread #{Thread.current.object_id}] running")

          if [2, 3].include?(thread_index)
            sleep(3)

            raise StandardError, 'Random Exception'
          end

          sleep 1
        end

        $logger.info("[Thread #{Thread.current.object_id}] terminating gracefully")
      rescue Exception => error
        $running = false
        $errors << [Thread.current, error]
        $logger.error("[Thread #{Thread.current.object_id}] terminating due to unhandled error")
      end
    end
  end
end

begin
  spawn_threads(5)

  while $running
    $logger.info("[Thread #{Thread.current.object_id}*] running")

    sleep 1

    # raise StandardError, "An unhandled error occurred in main thread #{Thread.current.object_id}"
  end
rescue Exception => error
  $running = false
  $errors << [Thread.current, error]
  $logger.error("[Thread #{Thread.current.object_id}*] terminating due to unhandled error")
end

$threads.each do |thread|
  $logger.info("[Thread #{Thread.current.object_id}*] joining thread #{thread.object_id}")
  thread.join
  $logger.info("[Thread #{Thread.current.object_id}*] joined thread #{thread.object_id}")
end

unless $errors.empty?
  $errors.each do |thread_error|
    thread, error = thread_error

    $logger.error("[Thread #{thread.object_id}] terminated due to unhandled error: #{error.message}")
  end

  exit(1)
end
