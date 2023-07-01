module Messages
  module User
    module_function

    def created(email:)
      { email: email }
    end

    def sync
      nil
    end

    def synced
      nil
    end
  end
end
