class UsersController < ApplicationController
    before_filter :authenticate_user!, except: [:new, :create]
    before_filter :admin_users, only: [:index]
    #:can_modify (through can_modify_base) also sets @user
    before_filter :can_modify, only: [:show, :edit, :update, :destroy]

    def index
    end
    
    def show
    end

    def new
        @user = User.new
    end
    
    def create
        @user = User.new(params[:user])
        if @user.save
            sign_in @user
            flash[:success] = "Welcome!"
            redirect_to root_url
        else
            render 'new'
        end
    end

    def edit
    end

    def update
        if @user.update_attributes(params[:user])
            flash[:success] = "Updated"
            sign_in @user
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
            flash[:success] = "Your account has been deleted"
        else
            redirect_to users_url
            flash[:success] = "User Destroyed"
        end
    end

private
    def can_modify
        can_modify_base(params[:id])
    end
end
