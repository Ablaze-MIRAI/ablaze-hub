Rails.application.routes.draw do
  get 'settings/profile'
  get 'settings/admin'
  get 'settings/appearance'
  get 'settings/sessions'
  get 'settings/security'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  root "application#index"

  # User Flows
  get "registration", to: "flows#registration"
  post "registration", to: "flows#registration_submit"
  get "login", to: "flows#login"
  post "login", to: "flows#login_submit"
  get "errors", to: "flows#errors"
  get "logout", to: "flows#logout"
  get "recovery", to: "flows#recovery"
  post "recovery", to: "flows#recovery_submit"
  get "verification", to: "flows#verification"
  post "verification", to: "flows#verification_submit"

  get "whoami", to: "application#whoami"
end
