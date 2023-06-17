module Queues
  module Default
    module_function

    def id
      Models::Queue.find_or_create_by(name: 'default').id
    end
  end
end
