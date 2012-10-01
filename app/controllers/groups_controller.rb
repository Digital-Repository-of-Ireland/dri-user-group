class GroupsController < ApplicationController
    #:index
    #:show
    #:new
    #:create
    #:edit
    #:update
    #:destroy

    before_filter :authenticate_user!
    #Unsure about index being for admins only (if users want to request a group to join)
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
            redirect_to root_url
        else
            render 'new'
        end
    end

    def edit
        @group = Group.find(params[:id])
    end

    def update
        @group = Group.find(params[:id])
        if @group.update_attributes(params[:group])
            flash[:success] = "Updated!"
            redirect_to @group
        else
            render 'edit'
        end
    end

    def destroy
        #Does not use @group for some reason described in tutorials
        deleting_group = Group.find(params[:id])
        #Need error check
        #Should do group deletion etc...
        deleting_group.destroy
    
        redirect_to groups_path
        flash[:success] = "Group has been deleted"
    end

    #Should these have their own controller and views?
    #TDOO:: Test what happens if user gets deleted while being member of group and vice versa
    #POST? PUT
    def add_user
        user_id = params[:user_id]
        @group = Group.find(params[:id])
        @group.join_group(user_id)
    end

    #DELETE
    def remove_user
    end

    private
        #copy of method from static controller and users controller
        def admin_users
            if !current_user.is_admin?
                flash[:error] = "You must be an admin"
                redirect_to(root_url)
            end
        end
end