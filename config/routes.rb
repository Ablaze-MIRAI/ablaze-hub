Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  root "application#index"

  get "registration", to: "flows#registration"
  post "registration", to: "flows#registration_submit"

  get "login", to: "flows#login"
  post "login", to: "flows#login_submit"

  get "errors", to: "flows#errors"

  get "whoami", to: "application#whoami"
end
