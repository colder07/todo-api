require "test_helper"

class Api::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "POST /api/v1/login returns a user when credentials are valid" do
    user = create_user
    post "/api/v1/login", params: { user: user_login_params_valid }

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
    create_user
    post "/api/v1/login", params: { user: user_login_params_invalid }

    assert_response :unauthorized

    body = JSON.parse(response.body)

    assert_instance_of Array, body["errors"]
    assert_equal "Invalid email or password", body["errors"][0]
  end

  test "POST /api/v1/login returns 401 when user does not exist" do
    post "/api/v1/login", params: { user: user_login_params_invalid }

    assert_response :unauthorized

    body = JSON.parse(response.body)
    assert_instance_of Array, body["errors"]
    assert_equal "Invalid email or password", body["errors"][0]
  end

  private

  def create_user(email: "test@example.com", password: "password123", password_confirmation: "password123")
    User.create!(email: email, password: password, password_confirmation: password_confirmation)
  end

  def user_login_params_valid
    {
      email: "test@example.com",
      password: "password123"
    }
  end

  def user_login_params_invalid
    {
      email: "test@example.com",
      password: "wrongpassword"
    }
  end
end
