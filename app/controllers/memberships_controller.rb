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
            #I dont really want to render this (Need error message)
            render 'users/edit'
        end
        #respond_with @user#, edit_user_path(@user)
        #redirect_to edit_user_path @user
    end

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
    def can_modify
        user_to_modify = User.find(params[:membership][:user_id])
        can_modify_base(user_to_modify)
    end
end