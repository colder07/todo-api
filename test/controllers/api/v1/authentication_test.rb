require "test_helper"

class Api::V1::AuthenticationTest < ActionDispatch::IntegrationTest
  test "GET /api/v1/todos returns 401 without authentication" do
    get "/api/v1/todos"

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_instance_of Array, body["errors"]
    assert_equal "Unauthorized", body["errors"][0]
  end

  test "GET /api/v1/todos returns 401 with an invalid token" do
    get "/api/v1/todos", headers: {
      Authorization: "Bearer invalid_token"
    }

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_instance_of Array, body["errors"]
    assert_equal "Unauthorized", body["errors"][0]
  end

  test "GET /api/v1/todos returns todos with a valid token" do
    user = User.create!(user_params)
    token = JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base, "HS256")

    get "/api/v1/todos", headers: {
      Authorization: "Bearer #{token}"
    }
    assert_response :ok
  end

  def user_params
    {
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    }
  end
end
