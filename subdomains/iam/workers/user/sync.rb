require 'active_record'
require 'objspace'
# require 'gc'

module IAM
  module Workers
    module User
      class Sync
        include Sidekiq::Job

        def get_metrics
          connection_pool = ActiveRecord::Base.connection_pool

          {
            total_connections: connection_pool.size,
            in_use_connections: connection_pool.connections.sum { |c| c.in_use? ? 1 : 0 },
            idle_connections: connection_pool.connections.sum { |c| c.in_use? ? 0 : 1 },
            waiting_connections: connection_pool.num_waiting_in_queue,
            total_memory: `free -m`.split("\n")[1].split[1],
            used_memory: `free -m`.split("\n")[1].split[2],
            free_memory: `free -m`.split("\n")[1].split[3],
            total_objects: ObjectSpace.count_objects[:TOTAL],
            free_objects: ObjectSpace.count_objects[:FREE],
            # gc_stats: GC.stat
          }
        end

        def create_memory_leak
          @leak ||= []
          1000.times { @leak << "a" * (1024**2) } # each string is approximately 1MB
        end

        def perform(*args)
          Sidekiq.logger.info 'IAM::Workers::User::Sync.perform started'

          metrics = get_metrics
          Sidekiq.logger.info "Metrics: \n#{JSON.pretty_generate(metrics)}"

          # sleep(10)

          # create_memory_leak

          metrics = get_metrics
          Sidekiq.logger.info "Metrics: \n#{JSON.pretty_generate(metrics)}"

          Synced.perform_async(args[0])

          Sidekiq.logger.info 'IAM::Workers::User::Sync.perform finished'
        end
      end
    end
  end
end
