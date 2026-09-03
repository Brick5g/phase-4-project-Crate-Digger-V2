Rails.application.routes.draw do
  root "home#index"

  get "/signup", to: "users#new"
  post "/signup", to: "users#create"

  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"

  delete "/logout", to: "sessions#destroy"

  get "/music-search", to: "music_searches#index", as: :music_search

  get "/music-search/artists/:musicbrainz_id", to: "music_searches#artist", as: :music_search_artist

  post "/music-search/releases/:musicbrainz_id", to: "music_searches#import", as: :import_music_release

  resources :artists
  resources :genres

  resources :records, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
    resources :collection_entries, only: [ :new, :create ]
    resources :record_genres, only: [ :new, :create ]
    resources :reviews, only: [ :new, :create ]
  end

  resources :collection_entries, only: [ :index, :edit, :update, :destroy ]
  resources :record_genres, only: [ :destroy ]
  resources :reviews, only: [ :edit, :update, :destroy ]
end
