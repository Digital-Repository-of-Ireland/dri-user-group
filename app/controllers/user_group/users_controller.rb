# frozen_string_literal: true

require_dependency 'user_group/application_controller'

module UserGroup
  class UsersController < ApplicationController
    before_action :set_initials, only: [:index]
    before_action :validate_cloudflare_turnstile, only: [:create]
    before_action :authenticate_user!, except: %i[new create show]
    # :can_modify (through can_modify_base) also sets @user
    before_action :can_modify?, only: %i[edit update destroy create_token destroy_token]
    before_action :can_view_profile, only: [:show]

    def index
      @view = params[:view].presence || 'index'

      if current_user.is_admin?
        if @view == 'report'
          @audit = PaperTrail::Version.order('created_at ASC').all
          return
        end

        @users = admin_users_scope
      else
        # Must be logged in so show all users that are public/registered
        @users = User.where(view_level: SETTING_PROFILE_INDEX_VIEW_LEVELS)
                     .order(SETTING_ORDER_USER)
                     .page(params[:page])
      end
    end

    def show; end

    def new
      @user = User.new
      @user.apply_omniauth(session[:omniauth]) if session[:omniauth]
    end

    def create
      @user = User.new(user_params)
      @user.apply_omniauth(session[:omniauth]) if session[:omniauth]

      if @user.valid? && @user.save
        join_default_group(@user)
        flash_and_redirect_after_create
        session[:omniauth] = nil
      else
        render 'new'
      end
    end

    def edit; end

    def update
      current_password = params[:user].delete(:current_password)

      if current_password_missing_or_invalid?(current_password)
        flash[:error] = I18n.t('user_groups.users.wrong_password')
        redirect_to edit_user_path(@user)
        return
      end

      strip_blank_password_params!

      if @user.update(user_params)
        flash[:success] = I18n.t('user_groups.shared.updated')
        bypass_sign_in @user if modifying_current_user?(@user)
        redirect_to @user
      else
        render 'edit'
      end
    end

    def destroy
      # @user is already set by the can_modify? before_action - no need to
      # re-look it up.
      deleting_self = modifying_current_user?(@user)
      @user.destroy

      if deleting_self
        flash[:success] = I18n.t('user_groups.users.deleted_self')
        redirect_to new_user_session_url
      else
        flash[:success] = I18n.t('user_groups.users.deleted')
        redirect_to users_url
      end
    end

    # Currently anyone who is logged in can create a token on their account
    def create_token
      @user.create_token
      @user.save
      flash[:success] = I18n.t('user_groups.users.token')
      redirect_to @user
    end

    def destroy_token
      @user.destroy_token
      if @user.save
        flash[:success] = I18n.t('user_groups.users.deleted_token')
        redirect_to @user
      else
        flash[:error] = I18n.t('user_groups.users.errors.deleted_token')
        render 'edit'
      end
    end

    def profile_redirect
      redirect_to current_user || new_user_session_path
    end

    private

    def admin_users_scope
      if params[:user_letter]
        User.by_letter(params[:user_letter]).order(SETTING_ORDER_USER).page(params[:page]).per(params[:per_page])
      elsif params[:search]
        User.search(params[:search]).order(SETTING_ORDER_USER).page(params[:page]).per(params[:per_page])
      else
        User.order(SETTING_ORDER_USER).page(params[:page]).per(params[:per_page])
      end
    end

    def join_default_group(user)
      group = UserGroup::Group.find_by_name(SETTING_GROUP_DEFAULT) ||
              UserGroup::Group.where(
                name: SETTING_GROUP_DEFAULT,
                description: 'Every user account is a member of this group.',
                is_locked: true
              ).first_or_create

      if group.id.nil?
        logger.error("ERROR @ SignUp:: group #{SETTING_GROUP_DEFAULT} does NOT exist")
        return
      end

      membership = user.join_group(group.id)
      membership.approve_membership(user.id)
      membership.save
    end

    def flash_and_redirect_after_create
      if user_signed_in? && current_user.is_admin?
        flash[:success] = I18n.t('user_groups.users.account_created')
      else
        sign_in @user
        flash[:success] = I18n.t('user_groups.users.signup')
      end
      redirect_to @user
    end

    # Equivalent to the original (A || !B) && !(!C || D), simplified via
    # De Morgan's laws to (A || !B) && C && !D: a current password is only
    # required when password_required? is true, and only enforced when
    # you're editing yourself or you're not an admin.
    def current_password_missing_or_invalid?(current_password)
      must_confirm_password = modifying_current_user?(@user) || !current_user.is_admin?
      must_confirm_password && @user.password_required? && !@user.valid_password?(current_password)
    end

    # Remove password params entirely if the user left both fields blank,
    # so User#update doesn't try to validate/change the password.
    def strip_blank_password_params!
      return unless params[:user][:password].blank? && params[:user][:password_confirmation].blank?

      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    def user_params
      params.require(:user).permit(:first_name, :second_name, :email, :password, :password_confirmation, :remember_me,
                                   :token_creation_date)
    end

    def can_modify?
      can_modify_base?(params[:id])
    end

    def can_view_profile
      # Check user profile exists
      # If the profile is set to public then grant view
      # If the profile is set to registered then check logged in
      # If the profile is set to private then check can_modify
      user_to_view = User.find_by_id(params[:id])

      unless user_to_view
        flash[:error] = I18n.t('user_groups.shared.errors.user')
        redirect_to main_app.root_url
        return
      end

      public_level = PROFILE_VIEW_LEVELS[1]
      registered_level = PROFILE_VIEW_LEVELS[2]

      unless user_to_view.get_view_level == public_level
        return unless signed_in

        can_view = user_to_view.get_view_level == registered_level ||
                   current_user.is_admin? ||
                   modifying_current_user?(user_to_view)

        unless can_view
          flash[:error] = I18n.t('user_groups.application.errors.permission')
          redirect_to main_app.root_url
          return
        end
      end

      @user = user_to_view
    end

    def set_initials
      @first_letters = User
                       .select('DISTINCT LOWER(SUBSTR(user_group_users.second_name, 1, 1)) AS name')
                       .order('name')
                       .collect(&:name)
    end
  end
end
