class UsersController < ApplicationController
    before_filter :authenticate_user!, except: [:new, :create]
    before_filter :admin_users, only: [:index]
    #:can_modify also sets @user
    before_filter :can_modify, only: [:show, :edit, :update, :destroy]

    def index
    end
    
    # 'home page' for user
    def show
    end

    #not sure what this does
    def new
        @user = User.new
    end
    
    #made a create which also saves a user
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

    # 'edit form' for user
    def edit
    end

    # saving changes from edit submission
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
    #Need a better check than email
    def modifying_current_user? (user_to_modify)
        return false unless current_user.email == user_to_modify.email
        return true
    end
    
    def can_modify
        user_to_modify = User.find(params[:id])
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
