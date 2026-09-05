require "test_helper"

class Api::V1::TodosControllerTest < ActionDispatch::IntegrationTest
  test "GET /api/v1/todos returns todos" do
    todo = Todo.create!(
      title: "Test Todo",
      description: "This is a test todo",
      completed: false
    )

    get "/api/v1/todos"
    assert_response :ok

    body = JSON.parse(response.body)

    returned_todo = body.find do |item|
      item["id"] == todo.id
    end

    assert_not_nil returned_todo
    assert_equal todo.title, returned_todo["title"]
  end
end
