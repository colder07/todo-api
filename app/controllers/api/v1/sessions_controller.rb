class Api::V1::SessionsController < ApplicationController
  def create
    user = User.find_by(email: user_login_params[:email])
    if user && user.authenticate(user_login_params[:password])
      token = JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base, "HS256")
      render json: { id: user.id, email: user.email, token: token }, status: :ok
    else
      render json: { errors: [ "Invalid email or password" ] }, status: :unauthorized
    end
  end

  private

  def user_login_params
    params.require(:user).permit(:email, :password)
  end
end
