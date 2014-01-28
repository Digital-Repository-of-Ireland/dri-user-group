module UserGroup
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
    def shibboleth
      find_or_create_user('shibboleth')
    end

    def find_or_create_user(auth_type)
      omniauth = request.env['omniauth.auth']
      create_method = "create_for_#{auth_type.downcase}".to_sym

      @user = UserGroup::User.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
      if @user
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => auth_type
        sign_in @user, :event => :authentication
        redirect_to main_app.root_url
      else
        @user = UserGroup::User.send(create_method, omniauth)
        if @user.save
          flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => auth_type
          sign_in @user, :event => :authentication
          redirect_to main_app.root_url
        else
          errors = @user.errors.full_messages.join(", ").html_safe
          flash[:error] = I18n.t "devise.omniauth_callbacks.failure", :kind => auth_type, :reason => errors
          session["devise.#{auth_type.downcase}_data"] = omniauth
          redirect_to request.env['omniauth.origin'] || main_app.root_url 
        end
      end
    end

    protected :find_or_create_user
  end
end
