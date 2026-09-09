require "test_helper"

class Api::V1::TodosControllerTest < ActionDispatch::IntegrationTest
  # GET /todos
  test "GET /api/v1/todos returns todos" do
    user1 = create_user
    user2 = create_user("test2@example.com")
    todoA = create_todo(user1, "Test todo A")
    todoB = create_todo(user1, "Test todo B")
    todoC = create_todo(user2, "Test todo C")
    todoD = create_todo(user2, "Test todo D")

    get "/api/v1/todos", headers: authenticated_headers(user1)
    assert_response :ok

    body = JSON.parse(response.body)

    assert_equal 2, body.length

    returned_ids = body.map { |t| t["id"] }.sort
    expected_ids = [ todoA.id, todoB.id ].sort
    assert_equal expected_ids, returned_ids

    assert_equal todoA.title, body.find { |t| t["id"] == todoA.id }["title"]
    assert_equal todoB.title, body.find { |t| t["id"] == todoB.id }["title"]
  end

  # GET /todos/:id
  test "GET /api/v1/todos/:id returns a todo" do
    user1 = create_user
    user2 = create_user("test2@example.com")
    todoA = create_todo(user1, "Test todo A")
    todoB = create_todo(user2, "Test todo B")

    get "/api/v1/todos/#{todoA.id}", headers: authenticated_headers(user1)
    assert_response :ok

    body = JSON.parse(response.body)
    assert_equal todoA.id, body["id"]
  end

  test "GET /api/v1/todos/:id returns 404 when todo belongs to another user" do
    user1 = create_user
    user2 = create_user("test2@example.com")
    todoA = create_todo(user1, "Test todo A")
    todoB = create_todo(user2, "Test todo B")

    get "/api/v1/todos/#{todoB.id}", headers: authenticated_headers(user1)
    assert_response :not_found

    body = JSON.parse(response.body)
    assert_instance_of Array, body["errors"]
    assert_not_empty body["errors"]
  end

  test "GET /api/v1/todos/:id returns 404 when todo does not exist" do
    user = create_user
    todo = create_todo(user)
    todo.destroy!

    get "/api/v1/todos/#{todo.id}", headers: authenticated_headers(user)
    assert_response :not_found

    body = JSON.parse(response.body)
    assert_instance_of Array, body["errors"]
    assert_not_empty body["errors"]
  end

  # POST /todos
  test "POST /api/v1/todos creates a todo" do
    user = create_user
    post "/api/v1/todos", params: {
      todo: {
        title: "Test todo",
        description: "This is a test todo",
        completed: false
      }
    }, headers: authenticated_headers(user)

    assert_response :created

    body = JSON.parse(response.body)
    assert_equal "Test todo", body["title"]
    assert_equal "This is a test todo", body["description"]
    assert_equal false, body["completed"]

    created_todo = Todo.find(body["id"])
    assert_equal user.id, created_todo.user_id
  end

  test "POST /api/v1/todos returns 400 when todo params are missing" do
    todos_count_before = Todo.count
    user = create_user
    post "/api/v1/todos", params: {}, headers: authenticated_headers(user)

    assert_response :bad_request
    body = JSON.parse(response.body)

    assert_instance_of Array, body["errors"]
    assert_not_empty body["errors"]
    assert_equal todos_count_before, Todo.count
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

    puts body.inspect

    assert_instance_of Array, body["errors"]
    assert_equal "Title can't be blank", body["errors"][0]
    assert_equal todos_count_before, Todo.count
  end

  # PATCH /todos/:id
  test "PATCH /api/v1/todos/:id updates a todo" do
    user1 = create_user
    todoA = create_todo(user1)

    patch "/api/v1/todos/#{todoA.id}", params: {
      todo: {
        title: "Updated title"
      }
    }, headers: authenticated_headers(user1)

    assert_response :ok

    body = JSON.parse(response.body)
    assert_equal "Updated title", body["title"]
    assert_equal todoA.id, body["id"]
    assert_equal user1.id, body["user_id"]
  end

  test "PATCH /api/v1/todos/:id returns 404 when todo belongs to another user" do
    user1 = create_user
    user2 = create_user("test2@example.com")
    todoA = create_todo(user1)
    todoB = create_todo(user2, "Test todo B")

    patch "/api/v1/todos/#{todoB.id}", params: {
      todo: {
        title: "Updated title"
      }
    }, headers: authenticated_headers(user1)

    assert_response :not_found

    body = JSON.parse(response.body)

    assert_instance_of Array, body["errors"]
    assert_not_empty body["errors"]
    assert_equal "Test todo B", Todo.find(todoB.id).title
  end

  # DELETE /todos/:id
  test "DELETE /api/v1/todos/:id deletes a todo" do
    user1 = create_user
    todoA = create_todo(user1)

    delete "/api/v1/todos/#{todoA.id}", headers: authenticated_headers(user1)
    assert_response :no_content
    assert_equal false, Todo.exists?(todoA.id)
  end

  test "DELETE /api/v1/todos/:id returns 404 when todo belongs to another user" do
    user1 = create_user
    user2 = create_user("test2@example.com")
    todoA = create_todo(user1)
    todoB = create_todo(user2, "Test todo B")

    delete "/api/v1/todos/#{todoB.id}", headers: authenticated_headers(user1)
    assert_response :not_found

    body = JSON.parse(response.body)

    assert_instance_of Array, body["errors"]
    assert_not_empty body["errors"]
    assert_equal true, Todo.exists?(todoB.id)
  end

  private
  # Helper methods
  def create_user(email = "test@example.com", password = "password123", password_confirmation = "password123")
    User.create!(email: email, password: password, password_confirmation: password_confirmation)
  end

  def authenticated_headers(user)
    token = JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base, "HS256")
    { Authorization: "Bearer #{token}" }
  end

  def create_todo(user, title = "Test todo", description = "This is a test todo", completed = false)
    Todo.create!(user: user, title: title, description: description, completed: completed)
  end
end
