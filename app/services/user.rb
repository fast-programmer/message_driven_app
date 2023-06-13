module User
  module_function

  def create(email:, created_at: Time.now.utc)
    user = nil

    ActiveRecord::Base.transaction do
      user = Models::User.create!(email: email, created_at: created_at)
      user.events.create!(user_id: user.id, name: 'User.created', created_at: created_at)
    end

    user.readonly!
    user.freeze

    user
  end
end
