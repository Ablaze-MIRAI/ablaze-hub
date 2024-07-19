Rails.application.routes.draw do
  get 'settings', to: 'settings#index'
  get 'settings/profile'
  put 'settings/profile', to: 'settings#update_profile'
  get 'settings/admin'
  get 'settings/appearance'
  get 'settings/sessions'
  get 'settings/security'

  get "up" => "rails/health#show", as: :rails_health_check

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
end
