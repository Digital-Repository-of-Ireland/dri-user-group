UserGroup::Application.routes.draw do
  root :to => 'static#home'
  match '/help',  to: 'static#help'
  match '/home',  to: 'static#home'
  match '/admin', to: 'static#admin'
  
  devise_for :users, :skip => :registration
  resources :users
  resources :groups do
    delete 'remove_user'
  end

  resources :memberships, only: [:create, :destroy]
  #resources :memberships
end
