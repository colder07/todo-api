Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :todos
      resources :users, only: [ :create ]

      post "login", to: "sessions#create"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
