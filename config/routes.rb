require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  namespace :api, defaults: { format: :json } do
    resources :users, only: [:create]
  end

  scope :admin do
    namespace :messaging do
      resources :queues, param: :slug do
        resources :messages, only: [:show], controller: 'queues/messages'
        resources :handlers, only: [:show], controller: 'queues/handlers'
      end
    end
  end
end
