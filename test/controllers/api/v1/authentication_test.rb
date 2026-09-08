require "test_helper"

class Api::V1::AuthenticationTest < ActionDispatch::IntegrationTest
  test "GET /api/v1/todos returns 401 without authentication" do
    get "/api/v1/todos"

    assert_response :unauthorized
  end

  test "GET /api/v1/todos returns 401 with an invalid token" do
    get "/api/v1/todos", headers: {
      Authorization: "Bearer invalid_token"
    }

    assert_response :unauthorized
  end
end
