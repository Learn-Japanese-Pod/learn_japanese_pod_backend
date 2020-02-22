Rails.application.routes.draw do
  namespace :users do
    resources :push_tokens, only: [:create, :destroy]
  end

  namespace :push_notifications do
    resources :send, only: [:create]
  end
end
