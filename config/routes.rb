Rails.application.routes.draw do
  match "/auth/:provider/callback", to: "sessions#google_callback", via: [ :get, :post ]
  match "/auth/failure", to: "sessions#omniauth_failure", via: [ :get, :post ]

  resource :session, only: [ :new, :create, :destroy ]
  resources :users, only: [ :new, :create, :show, :edit, :update ]
  resources :competitions do
    resources :enrollments, only: [ :create, :destroy ]
    resources :climbs, only: [ :show ] do
      resource :attempt, only: [ :create, :update ], controller: "attempts"
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "about", to: "pages#about", as: :about
  get "terms", to: "pages#terms", as: :terms
  get "privacy", to: "pages#privacy", as: :privacy

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
