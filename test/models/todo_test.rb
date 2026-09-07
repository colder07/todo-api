require "test_helper"

class TodoTest < ActiveSupport::TestCase
  test "is valid with a title" do
    user = User.create!(email: "test@example.com")
    todo = Todo.new(title: "Test Todo", user: user)
    assert todo.valid?
  end

  test "is invalid without a title" do
    user = User.create!(email: "test@example.com")
    todo = Todo.new(title: nil, user: user)
    assert todo.invalid?
  end
end
