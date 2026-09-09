class ApplicationController < ActionController::API
  rescue_from ActionController::ParameterMissing, with: :parameter_missing
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def parameter_missing(error)
    render json: { errors: [ error.message ] }, status: :bad_request
  end

  def record_not_found(error)
    render json: { errors: [ error.message ] }, status: :not_found
  end

  def authenticate_user!
    auth_header = request.headers["Authorization"]
    unless auth_header
      render json: { errors: [ "Unauthorized" ] }, status: :unauthorized
      return
    end

    token = auth_header.split(" ").last

    begin
      payload = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: "HS256" }).first
      @current_user = User.find(payload["user_id"])
    rescue
      render json: { errors: [ "Unauthorized" ] }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
