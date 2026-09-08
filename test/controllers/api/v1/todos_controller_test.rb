require "test_helper"

class Api::V1::TodosControllerTest < ActionDispatch::IntegrationTest
  test "GET /api/v1/todos returns todos" do
    user = create_user
    todo = create_todo(user)

    get "/api/v1/todos", headers: authenticated_headers(user)
    assert_response :ok

    body = JSON.parse(response.body)

    returned_todo = body.find do |item|
      item["id"] == todo.id
    end

    assert_not_nil returned_todo
    assert_equal todo.title, returned_todo["title"]
  end

  test "GET /api/v1/todos/:id returns a todo" do
    user = create_user
    todo = create_todo(user)

    get "/api/v1/todos/#{todo.id}", headers: authenticated_headers(user)
    assert_response :ok

    body = JSON.parse(response.body)

    assert_equal todo.id, body["id"]
    assert_equal todo.title, body["title"]
  end

  test "GET /api/v1/todos/:id returns 404 when todo does not exist" do
    user = create_user
    todo = create_todo(user)
    todo.destroy!

    get "/api/v1/todos/#{todo.id}", headers: authenticated_headers(user)
    assert_response :not_found

    body = JSON.parse(response.body)
    assert_equal "Todo not found", body["error"]
  end

  test "POST /api/v1/todos creates a todo" do
    user = create_user
    post "/api/v1/todos", params: {
      todo: todo_params
    }, headers: authenticated_headers(user)

    assert_response :created

    body = JSON.parse(response.body)
    assert_equal todo_params[:title], body["title"]
    assert_equal todo_params[:description], body["description"]
    assert_equal todo_params[:completed], body["completed"]

    created_todo = Todo.find(body["id"])
    assert_equal user.id, created_todo.user_id
  end

  test "POST /api/v1/todos returns 422 when title is missing" do
    todos_count_before = Todo.count
    user = create_user
    post "/api/v1/todos", params: {
      todo: {
        title: ""
      }
    }, headers: authenticated_headers(user)

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_includes body, "Title can't be blank"
    assert_equal todos_count_before, Todo.count
  end

  test "PATCH /api/v1/todos/:id updates a todo" do
    user = create_user
    todo = create_todo(user)
    patch "/api/v1/todos/#{todo.id}", params: {
      todo: {
        title: "Updated title"
      }
    }, headers: authenticated_headers(user)
    assert_response :ok

    body = JSON.parse(response.body)
    assert_equal "Updated title", body["title"]
    assert_equal "Updated title", Todo.find(todo.id).title
  end

  test "DELETE /api/v1/todos/:id deletes a todo" do
    user = create_user
    todo = create_todo(user)

    delete "/api/v1/todos/#{todo.id}", headers: authenticated_headers(user)
    assert_response :no_content
    assert_equal false, Todo.exists?(todo.id)
  end

  private

  def create_user
    User.create!(email: "test@example.com", password: "password123", password_confirmation: "password123")
  end

  def authenticated_headers(user)
    token = JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base, "HS256")
    { Authorization: "Bearer #{token}" }
  end

  def create_todo(user)
    Todo.create!(todo_params.merge(user: user))
  end

  def todo_params
    {
      title: "Test Todo",
      description: "This is a test todo",
      completed: false
    }
  end
end
