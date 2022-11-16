Rails.application.routes.draw do
  resources :tasks
  #get 'home/index'
  root 'tasks#index' # set index as starting page
  #get 'home/show'
  #get 'home/addtask'
end
