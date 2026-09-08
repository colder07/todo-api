require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  test "POST /api/v1/users should create a new user" do
    post "/api/v1/users", params: { user: user_params }

    assert_response :created
  end

  private

  def user_params
    {
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    }
  end
end
