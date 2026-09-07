require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "user is valid with an email" do
    user = User.new(email: "test@example.com", password: "password123")
    assert user.valid?
  end

  test "user is invalid without an email" do
    user = User.new(email: "", password: "password123")
    assert_not user.valid?
  end

  test "user is invalid with a duplicate email" do
    User.create!(email: "test@example.com", password: "password123")
    duplicate_user  = User.new(email: "test@example.com", password: "password123")
    assert_not duplicate_user.valid?
  end

  test "user has many todos" do
    user = User.create!(email: "test@example.com", password: "password123")
    user.todos.create!(title: "Todo 1")
    user.todos.create!(title: "Todo 2")

    assert_equal 2, user.todos.count
  end
end
