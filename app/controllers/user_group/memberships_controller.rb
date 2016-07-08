require_dependency "user_group/application_controller"
require 'json'

module UserGroup
  class MembershipsController < ApplicationController
    before_filter :authenticate_user!
    before_filter :admin_users, only: [:create, :approve]
    #:can_modify (through can_modify_base) also sets @user (found by id ONLY)
    before_filter :can_modify, only: [:destroy]
    before_filter :collection_mgr_users, only: [:view_read_request]
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
        if params[:membership_type].present? && params[:membership_type] == 'pending'
          create_pending_membership(@user, group_id)
        else
          create_membership(@user, group_id)
        end
      end
    end

    def approve
      membership = Membership.find(params[:id])
      group = Group.find_by(id: membership.group_id)

      if (group.reader_group == true)
        approve_read(membership, group)
      else
        if(approve_membership(membership))
          flash[:success] = I18n.t("user_groups.memberships.approve")
        else
          flash[:error] = I18n.t("user_groups.memberships.errors.approving")
        end

        redirect_to :back
      end
    end
    
    def destroy
      group_id_or_name = params[:membership][:group_id]
      group = not_positive_integer?(group_id_or_name) ? Group.find_by_name(group_id_or_name.downcase) : Group.find_by_id(group_id_or_name)
      #Remove hardcoded registered

      if group.reader_group == true
        remove_read(group)
      else
        action = @user.leave_group(group.id) unless group.nil? or group.name==SETTING_GROUP_DEFAULT
        if action.nil?
          flash[:error] = I18n.t("user_groups.memberships.errors.membership")
        else
          render 'users/edit' and return if action.errors.count >0
          flash[:success] = I18n.t("user_groups.memberships.leave")
        end

        redirect_to :back
      end
    end

    def view_read_request
      @membership = Membership.find_by_id(params[:id])
      
      respond_to do |format|
        format.js
      end
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

    def approve_read(membership, group)
      unless group.reader_group == true
        flash[:error] = I18n.t("user_groups.application.errors.special_groups")
        redirect_to main_app.root_url
        return
      end

      user = User.find_by(id: membership.user_id)

      result = ActiveFedora::SolrService.query("#{Solrizer.solr_name('read_access_group', :stored_searchable, type: :symbol)}:#{group.name}")

      if result.count > 1
        flash[:error] = I18n.t("user_groups.application.errors.group_error")
        redirect_to main_app.root_url
        return
      end

      collection = SolrDocument.new(result.first)
      if can? :manage_collection, collection
        if(approve_membership(membership))
          flash[:success] = I18n.t("user_groups.memberships.approve")
          AuthMailer.approved_mail(user, group, 
            collection[Solrizer.solr_name('title', :stored_searchable, type: :string)].first).deliver
        else
          flash[:error] = I18n.t("user_groups.memberships.errors.approving")
        end
      else
        flash[:error] = I18n.t("user_groups.application.errors.manage_permission")
      end

      redirect_to :back
    end

    def create_membership(user, group_id)
      membership = user.join_group(group_id)
      render 'users/edit' and return if membership.errors.count >0
      if(approve_membership(membership))
        flash[:success] = I18n.t("user_groups.memberships.joined")
      else
        flash[:error] = I18n.t("user_groups.memberships.errors.approving")
      end

      redirect_to :back
    end

    def create_pending_membership(user, group_id)
      group = get_group(params[:membership][:group_id])

      action = user.join_group(group.id)
      render 'groups/index' and return if action.errors.count >0

      store_request_form(group.id)

      # inform managers for reader group requests
      if group.reader_group.present? && group.reader_group
        result = ActiveFedora::SolrService.query("id:#{group.name}")
        doc = SolrDocument.new(result.pop) if result.count > 0
        managers = doc[Solrizer.solr_name('manager_access_person', :stored_searchable, type: :symbol)]

        # if no manager set for this collection it could be inherited, iterate up the tree
        if managers.nil?
          doc[Solrizer.solr_name('ancestor_id', :stored_searchable, type: :text)].reverse_each do |ancestor|
            result = ActiveFedora::SolrService.query("id:#{ancestor}")
            ancestordoc = SolrDocument.new(result.pop) if result.count > 0
            managers = ancestordoc[Solrizer.solr_name('manager_access_person', :stored_searchable, type: :symbol)]
            break if managers.present? && managers.count > 0
          end
        end

        if managers.present? && managers.count > 0
          AuthMailer.pending_mail(managers, user.email, user_group.manage_group_url(group)).deliver
        end
      end

      flash[:success] = I18n.t('user_groups.views.partials.request_form.submitted')

      redirect_to :back
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

    def remove_read(group)
      membership = Membership.find_by(id: params[:id])
      user = User.find_by(id: membership.user_id)
      
      unless group.reader_group == true
        flash[:error] = I18n.t("user_groups.application.errors.special_groups")
        redirect_to main_app.root_url
        return
      end

      result = ActiveFedora::SolrService.query("#{Solrizer.solr_name('read_access_group', :stored_searchable, type: :symbol)}:#{group.name}")

      if result.count > 1
        flash[:error] = I18n.t("user_groups.application.errors.group_error")
        redirect_to main_app.root_url
        return
      end

      collection = SolrDocument.new(result.first)
      if can? :manage_collection, collection
        action = user.leave_group(group.id) unless group.nil? or group.name==SETTING_GROUP_DEFAULT
        if action.nil?
          flash[:error] = I18n.t("user_groups.memberships.errors.membership")
        else
          render 'users/edit' and return if action.errors.count >0
          if membership.approved?
            flash[:success] = I18n.t("user_groups.memberships.read_access_removed")
            AuthMailer.removed_mail(user, group,
              collection[Solrizer.solr_name('title', :stored_searchable, type: :string)].first).deliver
          else
            flash[:success] = I18n.t("user_groups.memberships.read_access_rejected")
            AuthMailer.rejected_mail(user, group,
              collection[Solrizer.solr_name('title', :stored_searchable, type: :string)].first).deliver
          end
        end
        redirect_to :back
      else
        flash[:error] = I18n.t("user_groups.application.errors.manage_permission")
        redirect_to main_app.root_url
      end
    end

    def store_request_form(group_id)
      membership = @user.memberships.find_by_group_id(group_id)

      membership.request_form[:name] = params[:name] if params[:name].present?
      membership.request_form[:organisation] = params[:organisation] if params[:organisation].present?
      membership.request_form[:position] = params[:position] if params[:position].present?

      if params[:use].present?
        use = {}
        case params[:use]
        when 'academic'
          use[:academic] = {}
          use[:academic][:project] = params[:academic_project] if params[:academic_project].present?
          use[:academic][:funder] = params[:academic_funder] if params[:academic_funder].present?
          use[:academic][:investigator] = params[:academic_investigators] if params[:academic_investigators].present?
        when 'research'
          use[:research] = {}
          use[:research][:description] = params[:research_description] if params[:research_description].present?
        when 'education'
          use[:education] = {}
          use[:education][:role] = params[:teaching_role] if params[:teaching_role].present?
          use[:education][:module] = params[:teaching_module] if params[:teaching_module].present?
          use[:education][:dates] = params[:teaching_dates] if params[:teaching_dates].present?
        when 'commercial'
          use[:commercial] = {}
          use[:commercial][:description] = params[:commercial_description] if params[:commercial_description].present?
        when 'other'
          use[:other] = {}
          use[:other][:description] = params[:other_description] if params[:other_description].present?
        end

        membership.request_form[:use] = use.to_json
      end

      membership.save
    end
  end
end
