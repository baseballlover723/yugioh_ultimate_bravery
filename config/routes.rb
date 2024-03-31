Rails.application.routes.draw do
  root 'homepage#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get "deck/create", "deck#create"
      get "deck/settings", to: "deck#settings", as: :deck_settings
      if Rails.env.development?
        get "deck/update_settings", to: "deck#update_settings", as: :deck_update_settings
        get "deck/reset_settings", to: "deck#reset_settings", as: :deck_reset_settings
      end
      resources :deck, only: [:index, :create, :show]
    end
  end

  get "/*path_id" => "homepage#index", path_id: /(?!api).*/
end
