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
            #do stuff the devise controller would
            flash[:success] = "Welcome!"
            sign_in @user
            redirect_to root_url
        else
            render 'new'
        end
    end

    def edit
    end

    def update
        #13.43 lesson 9 error check
        if @user.update_attributes(params[:user])
            flash[:success] = "Updated!"

            #Might sign out
            #sign_in @user
            redirect_to @user
        else
            render 'edit'
        end
    end

    #Dont forget to look at what devise does
    def destroy
        #Does not use @user for some reason described in tutorials
        deleting_user = User.find(params[:id])
        is_current_user = modifying_current_user?(deleting_user)

        #Should do group deletion etc...
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
        begin
            user_to_modify = User.find(params[:id])
        rescue ActiveRecord::RecordNotFound
              flash[:error] = "Could not find user"
              #should change later
              redirect_to root_path
              return
        end
        can_modify_base(user_to_modify)
    end
end
