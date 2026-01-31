Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root "reservations#index", as: :authenticated_root
  end

  unauthenticated do
    root to: redirect("/users/sign_in")
  end

  resources :reservations, only: [:index]

  namespace :admin do
    root "dashboard#index"
    get "dashboard", to: "dashboard#index"
  end
end
