Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development? # mount Letter Opener Web for development environment

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

  match "*unmatched_route", to: "errors#not_found", via: :all,
    constraints: ->(request) { !request.path.start_with?("/rails/active_storage/") }
end
