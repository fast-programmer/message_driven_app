module Messaging
  module Queue
    module_function

    def default_name
      'default'
    end

    def default_id
      Models::Messaging::Queue.find_or_create_by(name: default_name).id
    end
  end
end
