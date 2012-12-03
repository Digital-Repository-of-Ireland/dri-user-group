require_dependency "user_group/application_controller"

module UserGroup
    class UsersController < ApplicationController
        before_filter :authenticate_user!, except: [:new, :create]
        before_filter :admin_users, only: [:index]
        #:can_modify (through can_modify_base) also sets @user
        before_filter :can_modify, only: [:show, :edit, :update, :destroy]

        def index
            @users = User.order("second_name").page(params[:page])
        end
        
        def show
        end

        def new
            @user = User.new
        end
        
        def create
            @user = User.new(params[:user])
            if @user.save
                #Join group registered
                group_id = UserGroup::Group.find_by_name("registered").id
                membership = @user.join_group(group_id)
                membership.approve_membership(@user.id)
                #TODO:: what if it doesnt save
                membership.save

                sign_in @user
                flash[:success] = I18n.t("user_groups.users.signup")
                redirect_to root_url
            else
                render 'new'
            end
        end

        def edit
        end

        def update
            current_password = params[:user].delete(:current_password)
            unless current_user.is_admin?
                unless @user.valid_password?(current_password)
                    flash[:error] = "Invalid Password"
                    redirect_to :back
                    return
                end
            end
            #Remove password if not being updated
            if params[:user][:password].empty? && params[:user][:password_confirmation].empty?
                params[:user].delete(:password)
                params[:user].delete(:password_confirmation)
            end
            #Update user
            if @user.update_attributes(params[:user])
                flash[:success] = I18n.t("user_groups.shared.updated")
                (sign_in @user, bypass: true) if modifying_current_user?(@user)
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
                redirect_to root_url
                flash[:success] = I18n.t("user_groups.users.deleted_self")
            else
                redirect_to users_url
                
                flash[:success] = I18n.t("user_groups.users.deleted")
            end
        end

        private
            def can_modify
                can_modify_base(params[:id])
            end
    end
end
