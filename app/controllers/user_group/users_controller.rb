require_dependency "user_group/application_controller"

module UserGroup
  class UsersController < ApplicationController
    before_action :set_initials, only: [:index]
    before_action :authenticate_user!, except: [:new, :create, :show]
    #:can_modify (through can_modify_base) also sets @user
    before_action :can_modify, only: [:edit, :update, :destroy, :create_token, :destroy_token]
    before_action :can_view_profile, only: [:show]

    def index
      # default to index view
      @view = params[:view].present? ? params[:view] : 'index'

      if signed_in && current_user.is_admin?
        if @view == "report"
          @audit = PaperTrail::Version.order('created_at ASC').all
        else
          if params[:user_letter]
            @users = User.by_letter(params[:user_letter]).order(SETTING_ORDER_USER).page(params[:page]).per(params[:per_page])
          elsif params[:search]
            @users = User.search(params[:search]).order(SETTING_ORDER_USER).page(params[:page]).per(params[:per_page])
          else
            @users = User.order(SETTING_ORDER_USER).page(params[:page]).per(params[:per_page])
          end
        end
      else
        #Must be logged in so show all users that are public/registered
        @users = User.where(view_level: SETTING_PROFILE_INDEX_VIEW_LEVELS).order(SETTING_ORDER_USER).page(params[:page])
      end

      @users
    end

    def show
    end

    def new
      @user = User.new
      @user.apply_omniauth(session[:omniauth]) if session[:omniauth]
    end

    def create
      @user = User.new(user_params)

      if session[:omniauth]
        @user.apply_omniauth(session[:omniauth])
      end

      if @user.valid? && @user.save
        #Join group registered
        group = UserGroup::Group.find_by_name(SETTING_GROUP_DEFAULT)
        if group.nil?
          group = UserGroup::Group.where(name: SETTING_GROUP_DEFAULT, description: "Every user account is a member of this group.", is_locked: true).first_or_create
        end
        group_id = group.id
        if group_id.nil?
          logger.error("ERROR @ SignUp:: group "+SETTING_GROUP_DEFAULT+" does NOT exist")
        else
          membership = @user.join_group(group_id)
          membership.approve_membership(@user.id)
          membership.save
        end

        if user_signed_in? && current_user.is_admin?
          flash[:success] = I18n.t("user_groups.users.account_created")
          redirect_to @user
        else
          sign_in @user
          flash[:success] = I18n.t("user_groups.users.signup")
          redirect_to @user
        end
      else
        render 'new'
      end

      session[:omniauth] = nil unless @user.new_record?
    end

    def edit
    end

    def update
      current_password = params[:user].delete(:current_password)
      if modifying_current_user?(@user) || !current_user.is_admin?
        unless !@user.password_required? || @user.valid_password?(current_password)
          flash[:error] = I18n.t("user_groups.users.wrong_password")
          redirect_to edit_user_path(@user)
          return
        end
      end
      #Remove password if not being updated
      if (params[:user].has_key?(:password) && params[:user][:password].empty?) && (params[:user].has_key?(:password_confirmation) && params[:user][:password_confirmation].empty?)
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end
      #Update user
      if @user.update(user_params)
        flash[:success] = I18n.t("user_groups.shared.updated")
        bypass_sign_in @user if modifying_current_user?(@user)
        redirect_to @user
      else
        render 'edit'
      end
    end

    def destroy
      deleting_user = User.find(params[:id])
      is_current_user = modifying_current_user?(deleting_user)

      deleting_user.destroy

      if is_current_user
        flash[:success] = I18n.t("user_groups.users.deleted_self")
        redirect_to main_app.new_user_session_url
      else
        redirect_to users_url
        flash[:success] = I18n.t("user_groups.users.deleted")
      end
    end

    #Currently anyone who is logged in can create a token on their account
    def create_token
      @user.create_token
      @user.save
      redirect_to @user
      flash[:success] = I18n.t("user_groups.users.token")
    end

    def destroy_token
      @user.destroy_token
      if @user.save
        flash[:success] = I18n.t("user_groups.users.deleted_token")
        redirect_to @user
      else
        render 'edit'
        flash[:error] = I18n.t("user_groups.users.errors.deleted_token")
      end
    end

    def profile_redirect
      if current_user
        redirect_to current_user
      else
        redirect_to new_user_session_path
      end
    end

    private
    def user_params
      params.require(:user).permit(:first_name, :second_name, :email, :password, :password_confirmation, :remember_me, :token_creation_date)
    end

    def can_modify
      can_modify_base(params[:id])
    end

    def can_view_profile
      #Check user profile exists
      #If the profile is set to public then grant view
      #If the profile is set to registered then check logged in
      #If the profile is set to private then check can_modify
      user_to_view = User.find_by_id(params[:id])
      if user_to_view.nil?
        flash[:error] = I18n.t("user_groups.shared.errors.user")
        redirect_to main_app.root_url
        return
      end

      unless user_to_view.get_view_level==PROFILE_VIEW_LEVELS[1]
        return unless signed_in
        unless user_to_view.get_view_level==PROFILE_VIEW_LEVELS[2]
          unless (current_user.is_admin? || modifying_current_user?(user_to_view) )
            flash[:error] = I18n.t("user_groups.application.errors.permission")
            redirect_to main_app.root_url
            return
          end
        end
      end

      @user = user_to_view
    end

    def set_initials
      @first_letters = User.select("DISTINCT LOWER(SUBSTR(user_group_users.second_name, 1, 1)) AS name").order("name").collect{|fl| "#{fl.name}"}
    end
  end
end
