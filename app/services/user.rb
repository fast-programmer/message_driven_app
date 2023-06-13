module User
  extend self

  def create(name:)
    ActiveRecord::Base.transaction do
      user = User.create!(email: 'tester@fastprogrammer.co')
      user.events.create!(type: 'User.created')
    end

    user.readonly!
    user.freeze

    user
  end
end
