Rails.application.routes.draw do
  devise_for :users
  devise_scope :user do  
    get '/users/sign_out' => 'devise/sessions#destroy'
    get '/users/sign_in' => 'devise/sessions#new'     
  end
  resources :tasks
  #get 'home/index'
  root 'tasks#index' # set index as starting page
  #get 'home/show'
  #get 'home/addtask'
end
