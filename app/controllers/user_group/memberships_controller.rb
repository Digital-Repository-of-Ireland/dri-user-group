require_dependency "user_group/application_controller"
require 'json'

module UserGroup
  class MembershipsController < ApplicationController
    before_action :authenticate_user!
    before_action :admin_users, only: [:create, :approve]
    #:can_modify (through can_modify_base) also sets @user (found by id ONLY)
    before_action :can_modify, only: [:destroy]
    before_action :collection_mgr_users, only: [:approve_read, :remove_read, :view_read_request]
    #remote true sends requests in js
    respond_to :html, :js

    def create
      @user = get_user(params[:membership][:user_id])
      group_id = get_group_id(params[:membership][:group_id])

      if @user.nil?
        flash[:error] = I18n.t("user_groups.shared.errors.user")
      elsif group_id.nil?
        flash[:error] = I18n.t("user_groups.memberships.errors.group")
      else
        membership = @user.join_group(group_id)
        render 'users/edit' and return if membership.errors.count >0
        if(approve_membership(membership))
          flash[:success] = I18n.t("user_groups.memberships.joined")
        else
          flash[:error] = I18n.t("user_groups.memberships.errors.approving")
        end
      end
      redirect_back(fallback_location:"/")
    end

    def destroy
      group_id_or_name = params[:membership][:group_id]
      group = not_positive_integer?(group_id_or_name) ? Group.find_by_name(group_id_or_name.downcase) : Group.find_by_id(group_id_or_name)
      #Remove hardcoded registered
      action = @user.leave_group(group.id) unless group.nil? or group.name==SETTING_GROUP_DEFAULT
      if action.nil?
        flash[:error] = I18n.t("user_groups.memberships.errors.membership")
      else
        render 'users/edit' and return if action.errors.count >0
        flash[:success] = I18n.t("user_groups.memberships.leave")
      end
      redirect_back(fallback_location:"/")
    end

    def approve
      membership = Membership.find_by_id(params[:id])
      if(approve_membership(membership))
        flash[:success] = I18n.t("user_groups.memberships.approve")
      else
        flash[:error] = I18n.t("user_groups.memberships.errors.approving")
      end
      redirect_back(fallback_location:"/")
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
      return not_positive_integer?(group_id_or_name) ? get_group_id_from_group_name(group_id_or_name) : group_id_or_name
    end

    def get_group(group_id_or_name)
      return group = Group.find(not_positive_integer?(group_id_or_name) ? get_group_id_from_group_name(group_id_or_name) : group_id_or_name)
    end

    def get_group_id_from_group_name(group_name)
      group = Group.find_by_name(group_name.downcase)
      return group.id unless group.nil?
    end

    def not_positive_integer?(string)
      return true unless string =~ /^[0-9]+$/
    end

  end
end
