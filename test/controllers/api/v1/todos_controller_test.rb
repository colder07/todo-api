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

  test "GET /api/v1/todos/:id returns a todo" do
    todo = Todo.create!(
      title: "Test Todo",
      description: "This is a test todo",
      completed: false
    )

    get "/api/v1/todos/#{todo.id}"
    assert_response :ok

    body = JSON.parse(response.body)

    assert_equal todo.id, body["id"]
    assert_equal todo.title, body["title"]
  end

  test "GET /api/v1/todos/:id returns 404 when todo does not exist" do
    todo = Todo.create!(
      title: "Test Todo",
      description: "This is a test todo",
      completed: false
    )
    todo.destroy!

    get "/api/v1/todos/#{todo.id}"
    assert_response :not_found

    body = JSON.parse(response.body)
    assert_equal "Todo not found", body["error"]
  end
end
