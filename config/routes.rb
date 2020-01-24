Rails.application.routes.draw do

  root 'static_pages#top'
  get '/signup', to: 'users#new'
  get '/search', to: 'users#search'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  get '/working_user', to: 'users#working_user'
  
  #勤怠変更のお知らせ
  get '/change_attendance', to: 'attendances#change_attendance_month'

  resources :users do
    collection {post :import}
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month' 
      patch 'attendances/update_month_request'
      get 'edit_overwork_request_approval'
      patch 'update_overwork_request_approval' 
      patch 'attendances/update_change_attendance_month'
      get 'attendances/attendance_log'
    end
   resources :attendances do
      member do
        get 'edit_overwork_request'
        patch 'update_overwork_request'
         get 'month_request_approval'
         patch 'update_month_request_approval'
      end
    end
  end
  
  resources :bases do
  end
end