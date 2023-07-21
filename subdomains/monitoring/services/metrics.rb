module Monitoring
  module Metrics
    module_function

    def dump
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
  end
end
