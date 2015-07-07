require_dependency "user_group/application_controller"

module UserGroup
  class MembershipsController < ApplicationController
    before_filter :authenticate_user!
    before_filter :admin_users, only: [:create, :approve]
    #:can_modify (through can_modify_base) also sets @user (found by id ONLY)
    before_filter :can_modify, only: [:destroy]
    before_filter :collection_mgr_users, only: [:approve_read, :remove_read]
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
      redirect_to :back
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
      redirect_to :back
    end

    def approve_read
      membership = Membership.find_by_id(params[:id])
      group = Group.find_by_id(membership.group_id)
      if group.reader_group.nil? || group.reader_group.eql?(false)
        flash[:error] = I18n.t("user_groups.application.errors.special_groups")
        redirect_to main_app.root_url
      end

      user = User.find_by_id(membership.user_id)

      result = ActiveFedora::SolrService.query("#{Solrizer.solr_name('read_access_group', :stored_searchable, type: :symbol)}:#{group.name}")

      if result.count > 1
        flash[:error] = I18n.t("user_groups.application.errors.group_error")
        redirect_to main_app.root_url
      end

      collection = SolrDocument.new(result.first)
      if can? :manage_collection, collection
        if(approve_membership(membership))
          flash[:success] = I18n.t("user_groups.memberships.approve")
          AuthMailer.approved_mail(user, group, collection[Solrizer.solr_name('title', :stored_searchable, type: :string)].first).deliver
        else
          flash[:error] = I18n.t("user_groups.memberships.errors.approving")
        end
      else
        flash[:error] = I18n.t("user_groups.application.errors.manage_permission")
      end
      redirect_to :back
    end

    def remove_read
      group_id_or_name = params[:membership][:group_id]
      group = not_positive_integer?(group_id_or_name) ? Group.find_by_name(group_id_or_name.downcase) : Group.find_by_id(group_id_or_name)
      user_id_or_email = params[:membership][:user_id]
      user = not_positive_integer?(user_id_or_email) ? User.find_by_id(user_id_or_email.downcase) : User.find_by_id(user_id_or_email)

      if group.reader_group.nil? || group.reader_group.eql?(false)
        flash[:error] = I18n.t("user_groups.application.errors.special_groups")
        redirect_to main_app.root_url
      end

      result = ActiveFedora::SolrService.query("#{Solrizer.solr_name('read_access_group', :stored_searchable, type: :symbol)}:#{group.name}")

      if result.count > 1
        flash[:error] = I18n.t("user_groups.application.errors.group_error")
        redirect_to main_app.root_url
      end

      collection = SolrDocument.new(result.first)
      if can? :manage_collection, collection
        action = user.leave_group(group.id) unless group.nil? or group.name==SETTING_GROUP_DEFAULT
        if action.nil?
          flash[:error] = I18n.t("user_groups.memberships.errors.membership")
        else
          render 'users/edit' and return if action.errors.count >0
          flash[:success] = I18n.t("user_groups.memberships.leave")
        end
        redirect_to :back
      else
        flash[:error] = I18n.t("user_groups.application.errors.manage_permission")
        redirect_to main_app.root_url
      end
    end

    def approve
      membership = Membership.find_by_id(params[:id])
      if(approve_membership(membership))
        flash[:success] = I18n.t("user_groups.memberships.approve")
      else
        flash[:error] = I18n.t("user_groups.memberships.errors.approving")
      end
      redirect_to :back
    end

    #Similar to create
    def pending
      @user = get_user(params[:membership][:user_id])
      group = get_group(params[:membership][:group_id])

      if @user.nil?
        flash[:error] = I18n.t("user_groups.shared.errors.user")
      elsif group.id.nil?
        flash[:error] = I18n.t("user_groups.memberships.errors.group")
      else
        action = @user.join_group(group.id)
        render 'groups/index' and return if action.errors.count >0

        # inform managers for reader group requests
        if group.reader_group.present? && group.reader_group.eql?(true)
          result = ActiveFedora::SolrService.query("id:#{group.name}")
          doc = SolrDocument.new(result.pop) if result.count > 0
          managers = doc[Solrizer.solr_name('manager_access_person', :stored_searchable, type: :symbol)]
          if managers.present? && managers.count > 0
            AuthMailer.pending_mail(managers, @user.email, user_group.manage_group_url(group)).deliver
          end
        end

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
