require "test_helper"

class Api::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "POST /api/v1/login returns a user when credentials are valid" do
    user = User.create!(user_create_params)
    post "/api/v1/login", params: { user: user_login_params }

    assert_response :ok

    body = JSON.parse(response.body)

    assert_equal user.id, body["id"]
    assert_equal user.email, body["email"]

    assert_not_nil body["token"]

    assert_nil body["password"]
    assert_nil body["password_confirmation"]
    assert_nil body["password_digest"]
  end

  test "POST /api/v1/login returns 401 when credentials are invalid" do
    User.create!(user_create_params)
    post "/api/v1/login", params: { user: { email: "test@example.com", password: "wrongpassword" } }

    assert_response :unauthorized

    body = JSON.parse(response.body)
    assert_equal "Invalid email or password", body["error"]
  end

  test "POST /api/v1/login returns 401 when user does not exist" do
    post "/api/v1/login", params: { user: user_login_params }

    assert_response :unauthorized

    body = JSON.parse(response.body)
    assert_equal "Invalid email or password", body["error"]
  end

  private
  def user_create_params
    {
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    }
  end

  def user_login_params
    {
      email: "test@example.com",
      password: "password123"
    }
  end
end
