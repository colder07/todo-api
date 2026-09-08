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
      JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: "HS256" })
    rescue
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
