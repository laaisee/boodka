Rails.application.routes.draw do
  get 'reconciliations/index'

  root 'accounts#index'
  resources :accounts
  resources :transactions
  resources :reconciliations
  resources :categories, except: :show
end
