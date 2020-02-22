Rails.application.routes.draw do
  namespace :users do
    resources :push_tokens, only: [:create, :destroy]
  end
end
