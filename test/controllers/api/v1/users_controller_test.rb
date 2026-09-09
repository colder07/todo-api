require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
    test "POST /api/v1/users creates a new user" do
        post "/api/v1/users", params: { user: user_params_valid }

        assert_response :created

        body = JSON.parse(response.body)
        assert_not_nil body["id"]
        assert User.exists?(body["id"])
        assert_equal user_params_valid[:email], body["email"]

        assert_nil body["password"]
        assert_nil body["password_confirmation"]
        assert_nil body["password_digest"]
    end

    test "POST /api/v1/users returns 422 when email is missing" do
        users_count_before = User.count
        post "/api/v1/users", params: { user: { email: "" } }

        assert_response :unprocessable_entity

        body = JSON.parse(response.body)

        assert_instance_of Array, body["errors"]
        assert_includes body["errors"], "Email can't be blank"
        assert_equal users_count_before, User.count
    end

    test "POST /api/v1/users returns 422 when email is duplicated" do
        User.create!(user_params_valid)
        users_count_before = User.count
        post "/api/v1/users", params: { user: user_params_valid }

        assert_response :unprocessable_entity

        body = JSON.parse(response.body)
        assert_instance_of Array, body["errors"]
        assert_includes body["errors"], "Email has already been taken"
        assert_equal users_count_before, User.count
    end

    test "POST /api/v1/users returns 422 when password is missing" do
        users_count_before = User.count
        post "/api/v1/users", params: { user: { email: "test@example.com", password: "", password_confirmation: "" } }

        assert_response :unprocessable_entity

        body = JSON.parse(response.body)

        assert_instance_of Array, body["errors"]
        assert_includes body["errors"], "Password can't be blank"
        assert_equal users_count_before, User.count
    end

    test "POST /api/v1/users returns 422 when password_confirmation does not match" do
        users_count_before = User.count
        post "/api/v1/users", params: { user: user_params_invalid }

        assert_response :unprocessable_entity

        body = JSON.parse(response.body)

        assert_instance_of Array, body["errors"]
        assert_includes body["errors"], "Password confirmation doesn't match Password"
        assert_equal users_count_before, User.count
    end


    private
    def user_params_valid
        {
        email: "test@example.com",
        password: "password123",
        password_confirmation: "password123"
        }
    end

    def user_params_invalid
      {
        email: "test@example.com",
        password: "password123",
        password_confirmation: "password1234"
      }
    end
end
