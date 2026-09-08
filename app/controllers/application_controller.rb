class ApplicationController < ActionController::API
  private

  def authenticate_user!
    auth_header = request.headers["Authorization"]
    unless auth_header
      render json: { error: "Unauthorized" }, status: :unauthorized
      return
    end

    token = auth_header.split(" ").last

    begin
      payload = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: "HS256" }).first
      @current_user = User.find(payload["user_id"])
    rescue
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
