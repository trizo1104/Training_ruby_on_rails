Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  get "up" => "rails/health#show", as: :rails_health_check

  root "assignments#index"

  resources :assignments do
    delete "images/:attachment_id", to: "assignments#remove_image", as: :image
  end
  resource :profile, only: %i[show edit update], controller: :users
end
