class MembershipsController < ApplicationController
    before_filter :authenticate_user!
    before_filter :admin_users, only: [:create, :approve]
    #:can_modify (through can_modify_base) also sets @user (found by id ONLY)
    before_filter :can_modify, only: [:destroy]
    #remote true sends requests in js
    respond_to :html, :js

    def create
        @user = get_user(params[:membership][:user_id])
        group_id = get_group_id(params[:membership][:group_id])

        if @user.nil?
            flash[:error] = "Could not find user"
        elsif group_id.nil?
            flash[:error] = "Could not find group"
        else
            membership = @user.join_group(group_id)
            render 'users/edit' and return if membership.errors.count >0
            if(approve_membership(membership))
                flash[:success] = "Joined Group"
            else
                flash[:error] = "Error Approving Membership"
            end
        end
        redirect_to :back
    end

    def destroy
        group_id = get_group_id(params[:membership][:group_id])
        action = @user.leave_group(group_id) unless group_id.nil?
        if action.nil?
            flash[:error] = "Could not find membership"
        else
            render 'users/edit' and return if action.errors.count >0
            flash[:success] = "Left Group"
        end
        redirect_to :back
    end

    def approve
        membership = Membership.find_by_id(params[:id])
        if(approve_membership(membership))
            flash[:success] = "Approved User"
        else
            flash[:error] = "Error Approving Membership"
        end
        redirect_to :back
    end

    #Similar to create
    def pending
        @user = get_user(params[:membership][:user_id])
        group_id = get_group_id(params[:membership][:group_id])

        if @user.nil?
            flash[:error] = "Could not find user"
        elsif group_id.nil?
            flash[:error] = "Could not find group"
        else
            action = @user.join_group(group_id)
            render 'groups/index' and return if action.errors.count >0
            flash[:success] = I18n.t("user_groups.memberships.pending")
        end
        redirect_to :back
    end


private
    def can_modify
        can_modify_base(params[:membership][:user_id])
    end

    def approve_membership(application)
        unless application.nil?
            application.approve_membership(current_user.id)
            application.save
            return true
        end
        return false
    end

    def get_user(user_id_or_name)
        return not_positive_integer?(user_id_or_name) ? User.find_by_email(user_id_or_name) : User.find_by_id(user_id_or_name)
    end

    def get_group_id(group_id_or_name)
        return not_positive_integer?(group_id_or_name) ? get_group_id_from_group(group_id_or_name) : group_id_or_name 
    end

    def get_group_id_from_group_name(group_name)
        group = Group.find_by_name(group_name.downcase)
        return group.id unless group.nil?
    end

    def not_positive_integer?(string)
        return true unless string =~ /^[0-9]+$/
    end
end