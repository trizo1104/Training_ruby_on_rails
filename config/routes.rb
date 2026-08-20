Rails.application.routes.draw do
  get "companies/index"
  # root "assignments#index"
  root "home#index"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development? # mount Letter Opener Web for development environment

  scope "/:locale", locale: /en|vi|ja/ do
    devise_for :users, controllers: {
      sessions: "users/sessions",
      registrations: "users/registrations",
      passwords: "users/passwords"
    }
    resources :assignments do
      delete "images/:attachment_id", to: "assignments#remove_image", as: :image
    end

    resources :users

    resources :companies

    get "up" => "rails/health#show", as: :rails_health_check

    resource :profile, only: %i[show edit update], controller: :users
  end

  match "*unmatched_route", to: "errors#not_found", via: :all,
    constraints: ->(request) { !request.path.start_with?("/rails/active_storage/") }
end
