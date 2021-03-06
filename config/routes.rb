require 'sidekiq/web'

Rails.application.routes.draw do
  get 'shopping_carts/index'
  mount Sidekiq::Web => '/jobmonitor'

  devise_for :users, as: "web"


  get  '/users/:id/profile', to: 'users#profile', as: "my_profile"
  get  '/users/:id/edit_profile', to: 'users#edit_profile', as: "edit_profile"
  get  '/users/set_current_locale', to: 'users#set_current_locale', as: "set_current_locale"


  resource :service do
    get '/index', to: "services#index"
    get '/shop', to: "services#shop"
    get '/facilities', to: "services#facilities"
    get '/individual', to: "services#individual"
    get '/appartments', to: "services#appartments"
    get '/get_time_slots', to: "services#get_time_slots"
    post '/book_appointment', to: "services#book_appointment"
  end

  root to: "services#index"

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  mount_devise_token_auth_for 'User', at: '/api/v1/users', controllers: {
    registrations: 'api/v1/registrations',
    sessions: 'api/v1/sessions',
    passwords: 'api/v1/passwords',
    token_validations: 'api/v1/token_validations'
  }, skip: %i[omniauth_callbacks registrations]

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get '/default_locales', to: 'api#default_locales'

      resource :user, only: %i[show update]

      devise_scope :user do
        resources :users, only: [] do
          controller :registrations do
            post :create, on: :collection
          end
        end
      end

      resource :ad do
        get '/fetch_ads', to: 'ads#ads'
      end

      resource :service do
        get '/fetch_services', to: 'services#fetch_services'
        get '/show_service', to: 'services#show_service'
        get '/time_slots', to: 'services#time_slots'
        post '/book_appointment', to: "services#book_appointment"

      end

      resource :camel do

        # search camels
        get '/search_camels', to: 'camels#search_camels'


        get '/fetch_camels', to: 'camels#fetch_camels'
        get '/show_camel', to: 'camels#show_camel'

        # route for Buy
        get '/fetch_camels_with_purpose', to: 'camels#fetch_camels_with_purpose'

        # routes for Bid
        get '/fetch_camels_with_prupose_bid_almost_over', to: 'camels#fetch_camels_with_prupose_bid_almost_over'
        get '/fetch_camels_with_prupose_bid_recently_added', to: 'camels#fetch_camels_with_prupose_bid_recently_added'

        # routes for Rent
        get '/fetch_camels_with_prupose_rent_for_competition', to: 'camels#fetch_camels_with_prupose_rent_for_competition'
        get '/fetch_camels_with_prupose_rent_for_rides', to: 'camels#fetch_camels_with_prupose_rent_for_rides'


        post '/create_camel', to: "camels#create_camel"

      end

      resource :bid do
        post '/create_bid', to: 'bids#create_bid'
      end

    end
  end
end
