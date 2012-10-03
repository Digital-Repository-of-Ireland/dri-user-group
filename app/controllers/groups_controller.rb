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
            #do stuff the devise controller would
            flash[:success] = "New Group!"
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
        if @group.is_locked?
            flash[:error] = "Group is locked"
            redirect_to @group
        elsif @group.update_attributes(params[:group])
            flash[:success] = "Updated!"
            redirect_to @group
        else
            render 'edit'
        end
    end

    def destroy
        #Does not use @group for some reason described in tutorials
        deleting_group = Group.find(params[:id])
        if deleting_group.is_locked?
            flash[:error] = "Group is locked"
            redirect_to deleting_group
        else
            #Need error check
            deleting_group.destroy unless deleting_group.is_locked
            redirect_to groups_path
            flash[:success] = "Group has been deleted"
        end
    end
    #is this the right way (I think so)
    def set_lock_status
        @group = Group.find(params[:id])
        @group.toggle_lock
        redirect_to @group
    end
end