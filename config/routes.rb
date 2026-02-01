Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root "reservations#index", as: :authenticated_root
  end

  unauthenticated do
    root to: redirect("/users/sign_in")
  end

  resources :reservations, only: [:index, :show, :new, :create, :destroy] do
    collection do
    post :confirm
  end

    member do
      get :confirmation
    end
  end

  namespace :admin do
    root "dashboard#index"
    get "dashboard", to: "dashboard#index"

      resources :time_slots, only: [:index, :new, :create, :edit, :update] do
      member { patch :toggle_active }
    end

      resources :reservations, only: [:index] do
      member { patch :cancel }
    end
  end
end
