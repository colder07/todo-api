class Api::V1::TodosController < ApplicationController
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    todos = current_user.todos
    render json: todos
  end

  def show
    todo = current_user.todos.find(params[:id])
    render json: todo
  end

  def create
    todo = Todo.new(todo_params.merge(user: current_user))
    if todo.save
      render json: todo, status: :created
    else
      render json: todo.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    todo = Todo.find(params[:id])
    if todo.update(todo_params)
      render json: todo, status: :ok
    else
      render json: todo.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    todo = Todo.find(params[:id])
    todo.destroy
    head :no_content
  end

  private

  def todo_params
    params.require(:todo).permit(:title, :description, :completed)
  end

  def record_not_found
    render json: { error: "Todo not found" }, status: :not_found
  end
end
