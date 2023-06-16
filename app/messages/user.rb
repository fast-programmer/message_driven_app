module Messages
  module User
    module_function

    def created(email:)
      OpenStruct.new(
        {
          body: { email: email }
        }.merge(name: build_name(__method__))
      )
    end

    def sync
      OpenStruct.new(
        {
          body: nil,
        }.merge(name: build_name(__method__))
      )
    end

    def synced
      OpenStruct.new(
        {
          body: nil,
        }.merge(name: build_name(__method__))
      )
    end

    def build_name(method_name)
      name + '.' + method_name.to_s
    end
  end
end
