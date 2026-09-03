Rails.application.routes.draw do
  root "home#index"

  get "/signup", to: "users#new"
  post "/signup", to: "users#create"

  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"

  delete "/logout", to: "sessions#destroy"

  resources :artists
  resources :genres

  resources :records, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
    resources :collection_entries, only: [ :new, :create ]
    resources :record_genres, only: [ :new, :create ]
  end

  resources :collection_entries, only: [ :index, :edit, :update, :destroy ]
  resources :record_genres, only: [ :destroy ]
end
