UserGroup::Engine.routes.draw do
  match '/', to: 'static#home'
  match '/help',  to: 'static#help'
  match '/home',  to: 'static#home'
  match '/admin', to: 'static#admin'
  
  devise_for :users, {
    :skip => :registration,
    class_name:     'UserGroup::User',
    module: :devise,
  }

  resources :users do
    get 'page/:page', :action => :index, :on => :collection
  end
  
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
