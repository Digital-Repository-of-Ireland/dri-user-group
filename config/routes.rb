UserGroup::Engine.routes.draw do
  root :to => 'static#home'
  match '/help',  to: 'static#help'
  match '/home',  to: 'static#home'
  match '/admin', to: 'static#admin'
  
  devise_for :users, {
    :skip => :registration,
    class_name:     'UserGroup::User',
    module: :devise,
  }

  resources :users
  resources :groups do
    member do
        put :lock
    end
  end
  resources :memberships, only: [:create, :destroy] do
    member do
        put :approve
    end
    collection do
        post :pending
    end
  end
end
