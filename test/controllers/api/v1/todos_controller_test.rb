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

  test "POST /api/v1/todos creates a todo" do
    post "/api/v1/todos", params: {
      todo: {
        title: "New Todo",
        description: "This is a new todo",
        completed: false
      }
    }
    assert_response :created

    body = JSON.parse(response.body)
    assert_not_nil body["id"]
    assert_equal "New Todo", body["title"]
    assert_equal "This is a new todo", body["description"]
    assert_equal false, body["completed"]

    assert Todo.exists?(body["id"])
  end

  test "POST /api/v1/todos returns 422 when title is missing" do
    todos_count_before = Todo.count
    post "/api/v1/todos", params: {
      todo: {
        title: ""
      }
    }
    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_includes body, "Title can't be blank"
    assert_equal todos_count_before, Todo.count
  end

  test "PATCH /api/v1/todos/:id updates a todo" do
    todo = Todo.create!(
      title: "Test Todo",
      description: "This is a test todo",
      completed: false
    )
    patch "/api/v1/todos/#{todo.id}", params: {
      todo: {
        title: "Updated title"
      }
    }
    assert_response :ok

    body = JSON.parse(response.body)
    assert_equal "Updated title", body["title"]
    assert_equal "Updated title", Todo.find(todo.id).title
  end

  test "DELETE /api/v1/todos/:id deletes a todo" do
    todo = Todo.create!(
      title: "Test Todo",
      description: "This todo is going to be deleted",
      completed: false
    )
    delete "/api/v1/todos/#{todo.id}"
    assert_response :no_content
    assert_equal false, Todo.exists?(todo.id)
  end
end
