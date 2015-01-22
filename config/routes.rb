UserGroup::Engine.routes.draw do
  get '/',      to: 'static#home'
  get '/help',  to: 'static#help'
  get '/home',  to: 'static#home'
  get '/admin', to: 'static#admin'

  #root :to => 'static#home'

  devise_for :users, {
    :skip => [:registration, :omniauth_callbacks],
    class_name:     'UserGroup::User',
    module: :devise,
  }

  resources :users do
    get 'page/:page', :action => :index, :on => :collection
    member do
      post :create_token
      delete :destroy_token
    end
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
