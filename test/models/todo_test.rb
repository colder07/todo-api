require "test_helper"

class TodoTest < ActiveSupport::TestCase
  test "todo is valid with a title" do
    user = User.create!(email: "test@example.com", password: "password123")
    todo = Todo.new(title: "Test Todo", user: user)
    assert todo.valid?
  end

  test "todo is invalid without a title" do
    user = User.create!(email: "test@example.com", password: "password123")
    todo = Todo.new(title: nil, user: user)
    assert todo.invalid?
  end

  test "todo is invalid without a user" do
    todo = Todo.new(title: "Test Todo")
    assert todo.invalid?
  end
end
