class MembershipsController < ApplicationController
    before_filter :authenticate_user!
    before_filter :admin_users, only: [:create]
    #:can_modify also sets @user
    before_filter :can_modify, only: [:destroy]

    respond_to :html, :js

    #Must be Admin for now (unless pending done in future)
    def create
        @user = User.find(params[:membership][:user_id])
        action = @user.join_group(params[:membership][:group_id])
        if action.errors.count == 0
            flash[:success] = "Joined Group"
            respond_with @user
        else
            render 'users/edit'
        end
        #respond_with @user#, edit_user_path(@user)
        #redirect_to edit_user_path @user
    end

    #Must be themselves or ADMIN
    def destroy
        action = @user.leave_group(params[:membership][:group_id])
        if action.errors.count == 0
            flash[:success] = "Left Group"
            respond_with @user
        else
            render 'users/edit'
        end
    end


private
    #Need a better check than email
    def modifying_current_user? (user_to_modify)
        return false unless current_user.email == user_to_modify.email
        return true
    end
    
    def can_modify
        user_to_modify = User.find(params[:membership][:user_id])
        if ! (current_user.is_admin? || modifying_current_user?(user_to_modify) )
            flash[:error] = "You do not have permission"
            redirect_to(root_url)
        end
        @user = user_to_modify
    end

    #copy of method from static controller
    def admin_users
        if !current_user.is_admin?
            flash[:error] = "You must be an admin"
            redirect_to(root_url)
        end
    end    
end