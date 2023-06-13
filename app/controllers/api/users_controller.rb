module Api
  class UsersController < ::ApplicationController
    def create
      user = User.create(email: user_params[:email])

      render json: user, status: :created
    rescue User::Error => e
      render json: { errors: e.message }, status: :unprocessable_entity
    end

    private

    def user_params
      params.require(:user).permit(:email)
    end
  end
end
