require_dependency "user_group/application_controller"

module UserGroup
  class GroupsController < ApplicationController
    before_action :authenticate_user!
    before_action :admin_users, except: [:index, :manage]

    def index
      @groups = Group.search(params[:search]).order(SETTING_ORDER_GROUP).page(params[:page])
    end

    def show
      @group = Group.find(params[:id])
    end

    def new
      @group = Group.new
    end

    def create
      @group = Group.new(group_params)
      if @group.valid? && @group.save
        flash[:success] = I18n.t("user_groups.groups.created")
        redirect_to @group
      else
        render 'new'
      end
    end

    def edit
      @group = Group.find(params[:id])
    end

    def update
      @group = Group.find(params[:id])
      return if is_locked?(@group)
      if @group.update_attributes(group_params)
        flash[:success] = I18n.t("user_groups.shared.updated")
        redirect_to @group
      else
        render 'edit'
      end
    end

    def destroy
      deleting_group = Group.find(params[:id])
      return if is_locked?(deleting_group)
      deleting_group.destroy
      flash[:success] = I18n.t("user_groups.groups.deleted")
      redirect_to groups_path
    end

    def lock
      @group = Group.find(params[:id])
      @group.toggle_lock
      @group.save
      if @group.is_locked?
        redirect_to group_path @group
      else
        redirect_to edit_group_path @group
      end
    end

    private
    def group_params
      params.require(:group).permit(:name, :description, :is_locked)
    end

    def is_locked?(group)
      if group.is_locked?
        flash[:error] = I18n.t("user_groups.groups.errors.locked")
        redirect_to group
        return true
      end
      return false
    end
  end
end
