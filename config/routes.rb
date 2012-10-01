UserGroup::Application.routes.draw do
  root :to => 'static#home'
  match '/help',  to: 'static#help'
  match '/home',  to: 'static#home'
  match '/admin', to: 'static#admin'
  
  devise_for :users, :skip => :registration
  resources :users
  resources :groups

  resources :memberships, only: [:create, :destroy]
end
