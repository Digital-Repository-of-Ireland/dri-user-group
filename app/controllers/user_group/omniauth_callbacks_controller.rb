module UserGroup
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def shibboleth
      find_or_create_user('shibboleth')
    end

    def find_or_create_user(auth_type)
      omniauth = request.env['omniauth.auth']

      authentication = UserGroup::Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
      if authentication
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: auth_type
        sign_in authentication.user, event: :authentication
        redirect_to main_app.root_path
      elsif current_user
        current_user.authentications.create!(provider: omniauth['provider'], uid: omniauth['uid'])
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: auth_type
        redirect_to main_app.root_path
      elsif create_user(auth_type, omniauth)
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: auth_type
        sign_in @user, event: :authentication
        redirect_to main_app.root_path
      else
        errors = @user.errors.full_messages.join(', ').html_safe
        flash[:alert] = I18n.t('user_groups.users.errors.missing_account_details', reason: errors)
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_path || main_app.root_path
      end
    end

    protected :find_or_create_user

    private

    def create_user(auth_type, omniauth)
      create_method = "create_for_#{auth_type.downcase}".to_sym
      @user = UserGroup::User.send(create_method, omniauth)

      return false unless @user.save

      # join registered group
      group = UserGroup::Group.where(name: SETTING_GROUP_DEFAULT,
                                     description: 'Every user account is a member of this group.', is_locked: true).first_or_create
      if group
        membership = @user.join_group(group.id)
        membership.approve_membership(@user.id)
        membership.save
      end
      true
    end
  end
end
