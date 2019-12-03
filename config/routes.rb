Rails.application.routes.draw do

  root 'static_pages#top'
  get '/signup', to: 'users#new'
  get '/search', to: 'users#search'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users do
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month' 
      get 'edit_overwork_request_approval'
    end
   resources :attendances do
      member do
        get 'edit_overwork_request'
        patch 'update_overwork_request'
      end
    end
  end
  
  resources :bases do
  end
end