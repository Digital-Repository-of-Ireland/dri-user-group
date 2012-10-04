class MembershipsController < ApplicationController
    before_filter :authenticate_user!
    before_filter :admin_users, only: [:create, :approve]
    #:can_modify (through can_modify_base) also sets @user
    before_filter :can_modify, only: [:destroy]

    respond_to :html, :js

    #Must be Admin for now (unless pending done in future)
    def create
        begin
            #Can find user by email or ID
            @user = nil
            if(not_positive_integer?(params[:membership][:user_id]))
                @user = User.find_by_email(params[:membership][:user_id])
            else
                @user = User.find_by_id(params[:membership][:user_id])
            end
        #crashes if user does not exist!
        rescue ActiveRecord::RecordNotFound
              flash[:error] = "Could not find user"
              #should change later
              redirect_to root_path
              return
        end
        #:group_id can also be name
        action = @user.join_group(params[:membership][:group_id]) unless @user.nil?
        if action.nil? || action.errors.count > 0
            render 'users/edit'
        else
            #error check this
            action.approve_membership(current_user.id)
            action.save
            flash[:success] = "Joined Group"
            redirect_to :back
        end
    end

    def destroy
        #Take in id instead??
        #:group_id can also be name
        action = @user.leave_group(params[:membership][:group_id])
        if action.errors.count == 0
            flash[:success] = "Left Group"
            #respond_with @user
             redirect_to :back

        else
            render 'users/edit'
        end
    end

    def approve
        #Need error check
        membership = Membership.find_by_id(params[:id])
        membership.approve_membership(current_user.id) unless membership.nil?
        #A way around? or error check here!
        membership.save
        flash[:success] = "Approved User"
        redirect_to :back
    end

    def pending
        begin
            #Can find user by email or ID
            @user = nil
            if(not_positive_integer?(params[:membership][:user_id]))
                @user = User.find_by_email(params[:membership][:user_id])
            else
                @user = User.find_by_id(params[:membership][:user_id])
            end
        #TODO:: FIX ALL crashes if user does not exist!
        rescue ActiveRecord::RecordNotFound
              flash[:error] = "Could not find user"
              #should change later
              redirect_to :back
              return
        end
        #:group_id can also be name
        
        action = @user.join_group(params[:membership][:group_id]) unless @user.nil?
        if action.errors.count > 0
            #I dont really want to render this (Need error message)
            #Render back to where the partials are
            redirect_to :back
        else
            #temporary here
            #action.approved_by = current_user.id
            #action.save
            #end temporary
            flash[:success] = "Application Pending for Group"
            redirect_to :back
        end
        #respond_with @user#, edit_user_path(@user)
        #redirect_to edit_user_path @user
    end


private
    def can_modify
        begin
            user_to_modify = User.find(params[:membership][:user_id])
        rescue ActiveRecord::RecordNotFound
              flash[:error] = "Could not find user"
              #should change later
              redirect_to root_path
              return
        end
        can_modify_base(user_to_modify)
    end

    #taken from user.rb
    def not_positive_integer?(string)
        return false if string =~ /^[0-9]+$/
        return true
    end

end