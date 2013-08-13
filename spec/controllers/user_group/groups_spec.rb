require 'spec_helper'

describe UserGroup::GroupsController do

  before(:each) do
    @routes = UserGroup::Engine.routes

    @login_user = FactoryGirl.create(:admin)
    sign_in @login_user
  end

  describe "GET #index" do
    it "populates an array of groups" do
      group = FactoryGirl.create(:group)
      group.save

      get :index
      assigns[:groups].should_not be_nil
      expect(assigns[:groups]).to match_array([UserGroup::Group.find_by_name(SETTING_GROUP_ADMIN), group])
    end
  end

  describe "GET #new" do
    it "assigns a new group" do
      get :new

      assigns(:group).should_not be_nil
      assigns(:group).should be_kind_of(UserGroup::Group)
    end
  end

  describe "GET #show" do 
    it "renders the #show view" do 
      @group = FactoryGirl.create(:group)
        
      get :show, id: @group 
      response.should render_template :show 
    end 
  end

  describe "POST create" do 
    context "with valid attributes" do 
      it "creates a new group" do 
        expect{ 
          post :create, group: FactoryGirl.attributes_for(:group) 
        }.to change(UserGroup::Group,:count).by(1) 
      end

      it "redirects to the new group" do 
        post :create, group: FactoryGirl.attributes_for(:group) 
        response.should redirect_to UserGroup::Group.last 
      end
    end

    context "with invalid attributes" do 
      it "does not save the new group" do 
        expect{ 
          post :create, group: FactoryGirl.attributes_for(:invalid_group) 
        }.to_not change(UserGroup::Group,:count).by(1) 
      end

      it "re-renders the new method" do 
        post :create, group: FactoryGirl.attributes_for(:invalid_group) 
        response.should render_template :new 
      end
    end
  end

  describe 'PUT update' do 
    before :each do 
      @group = FactoryGirl.create(:group) 
    end 

    context "valid attributes" do 
      it "located the requested @group" do 
        put :update, id: @group, 
        group: FactoryGirl.attributes_for(:group) 
        assigns(:group).should eq(@group) 
      end 

      it "changes @group's attributes" do 
        put :update, id: @group,
          group: FactoryGirl.attributes_for(:group, name: "group", description: "test")
        @group.reload 
        @group.name.should eq("group") 
        @group.description.should eq("test") 
      end 

      it "does not change locked group" do
        @group.toggle_lock
        @group.save

        put :update, id: @group,
          group: FactoryGirl.attributes_for(:group, name: "locked", description: "locked")
        @group.reload
        @group.name.should_not eq("locked")
        @group.description.should_not eq("locked")
      end

      it "redirects to the updated group" do 
        put :update, id: @group, group: FactoryGirl.attributes_for(:group) 
        response.should redirect_to @group
      end 
    end

    context "invalid attributes" do
      it "does not change @group's attributes" do
        name = @group.name

        put :update, id: @group,
          group: FactoryGirl.attributes_for(:group, name: nil, description: "tester")
        @group.reload
        @group.description.should_not eq("tester")
        @group.name.should eq(name)
      end

      it "re-renders the edit method" do
        put :update, id: @group, group: FactoryGirl.attributes_for(:invalid_group)
        response.should render_template :edit
      end
    end
  end
    
  describe 'DELETE destroy' do 
    before :each do 
      @group = FactoryGirl.create(:group) 
    end 
  
    it "deletes the group" do 
      expect{ 
        delete :destroy, id: @group 
      }.to change(UserGroup::Group,:count).by(-1) 
    end 
  end

  describe 'PUT lock' do
    before :each do
      @group = FactoryGirl.create(:group)
    end

    it "locks the group" do
      @group.is_locked?.should be_false

      put :lock, id: @group
      @group.reload
      @group.is_locked?.should be_true
    end

    it "unlocks the group" do
      @group.toggle_lock
      @group.save
      @group.is_locked?.should be_true

      put :lock, id: @group
      @group.reload
      @group.is_locked?.should be_false
    end
  end

end
