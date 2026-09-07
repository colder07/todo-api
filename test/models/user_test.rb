require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "user is valid with an email" do
    user = User.new(email: "test@example.com")
    assert user.valid?
  end

  test "user is invalid without an email" do
    user = User.new(email: "")
    assert_not user.valid?
  end

  test "user is invalid with a duplicate email" do
    User.create!(email: "test@example.com")
    duplicate_user  = User.new(email: "test@example.com")
    assert_not duplicate_user.valid?
  end
end
