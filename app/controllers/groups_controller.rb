class GroupsController < ApplicationController
    before_filter :authenticate_user!
    before_filter :admin_users, except: [:index]
    
    def index
    end

    def show
        @group = Group.find(params[:id])
    end

    def new
        @group = Group.new
    end

    def create
        @group = Group.new(params[:group])
        if @group.save
            flash[:success] = "Group Created"
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
        return if is_locked(@group)
        if @group.update_attributes(params[:group])
            flash[:success] = "Updated!"
            redirect_to @group
        else
            render 'edit'
        end
    end

    def destroy
        deleting_group = Group.find(params[:id])
        return if is_locked(deleting_group)
        deleting_group.destroy
        flash[:success] = "Group has been deleted"
        redirect_to groups_path
    end

    def lock
        @group = Group.find(params[:id])
        @group.toggle_lock
        @group.save
        if(@group.is_locked)
            redirect_to group_path @group
        else 
            redirect_to edit_group_path @group
        end
    end

    private
        def is_locked?(group)
            if group.is_locked?
                flash[:error] = "Group is locked"
                redirect_to group
                return true
            end
            return false
        end
end