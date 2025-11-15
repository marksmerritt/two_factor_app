Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions" }

  # Two-Factor Authentication routes
  get "two_factor_setup", to: "two_factor_setup#show", as: :two_factor_setup
  post "two_factor_setup/enable", to: "two_factor_setup#enable", as: :two_factor_setup_enable

  get "two_factor_verification", to: "two_factor_verification#show", as: :two_factor_verification
  post "two_factor_verification/verify", to: "two_factor_verification#verify", as: :two_factor_verification_verify

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "home#index"
end
