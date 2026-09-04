require "test_helper"

class TodoTest < ActiveSupport::TestCase
  test "is valid with a title" do
  todo = Todo.new(title: "Test Todo")
  assert todo.valid?
  end

  test "is invalid without a title" do
    todo = Todo.new(title: nil)
    assert todo.invalid?
  end
end
