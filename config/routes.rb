Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users
  get 'home/index'

  # You can have the root of your site routed with "root"
  root 'home#index'

  #-- API ---------------------------------------------------------------------------
  namespace :api , defaults: {format: :json} do
    #version 1
    namespace :v1 do
      # token authentication
      devise_scope :user do
        post 'registrations' => 'registrations#create' # /api/v1/registrations
        post 'login' => 'sessions#create'
        delete 'logout' => 'sessions#destroy'
      end
    end
  end
  #END API --------------------------------------------------------------------------


end
