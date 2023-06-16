module Messages
  module Account
    module_function

    def created(name:, slug:, owner_id:)
      OpenStruct.new(
        {
          body: { name: name, slug: slug, owner_id: owner_id }
        }.merge(name: build_name(__method__))
      )
    end

    def build_name(method_name)
      name + '.' + method_name.to_s
    end
  end
end
