require 'spec_helper'

describe UserGroup::GroupsController do

  before(:each) do
    @routes = UserGroup::Engine.routes

    @login_user = FactoryBot.create(:admin)
    @login_user.confirm
    sign_in @login_user
  end

  describe "GET #index" do
    it "populates an array of groups" do
      group = FactoryBot.create(:group)
      group.save

      get :index
      expect(assigns[:groups]).not_to be_nil
      expect(assigns[:groups]).to match_array([UserGroup::Group.find_by_name(SETTING_GROUP_ADMIN), group])
    end
  end

  describe "GET #new" do
    it "assigns a new group" do
      get :new

      expect(assigns(:group)).not_to be_nil
      expect(assigns(:group)).to be_kind_of(UserGroup::Group)
    end
  end

  describe "GET #show" do
    it "renders the #show view" do
      @group = FactoryBot.create(:group)

      get :show, params: { id: @group }
      expect(response).to render_template :show
    end
  end

  describe "POST create" do
    context "with valid attributes" do
      it "creates a new group" do
        expect{
          post :create, params: { group: FactoryBot.attributes_for(:group) }
        }.to change(UserGroup::Group,:count).by(1)
      end

      it "redirects to the new group" do
        post :create, params: { group: FactoryBot.attributes_for(:group) }
        expect(response).to redirect_to UserGroup::Group.last
      end
    end

    context "with invalid attributes" do
      it "does not save the new group" do
        count = UserGroup::Group.count
        expect{
          post :create, params: { group: FactoryBot.attributes_for(:invalid_group) }
        }.not_to change(UserGroup::Group,:count).from(count)
      end

      it "re-renders the new method" do
        post :create, params: { group: FactoryBot.attributes_for(:invalid_group) }
        expect(response).to render_template :new
      end
    end
  end

  describe 'PUT update' do
    before :each do
      @group = FactoryBot.create(:group)
    end

    context "valid attributes" do
      it "located the requested @group" do
        put :update, params: { id: @group, group: FactoryBot.attributes_for(:group) }
        expect(assigns(:group)).to eq(@group)
      end

      it "changes @group's attributes" do
        put :update, params: { id: @group, group: FactoryBot.attributes_for(:group, name: "group", description: "test") }
        @group.reload
        expect(@group.name).to eq("group")
        expect(@group.description).to eq("test")
      end

      it "does not change locked group" do
        @group.toggle_lock
        @group.save

        put :update, params: { id: @group,
          group: FactoryBot.attributes_for(:group, name: "locked", description: "locked") }
        @group.reload
        expect(@group.name).not_to eq("locked")
        expect(@group.description).not_to eq("locked")
      end

      it "redirects to the updated group" do
        put :update, params: { id: @group, group: FactoryBot.attributes_for(:group) }
        expect(response).to redirect_to @group
      end
    end

    context "invalid attributes" do
      it "does not change @group's attributes" do
        name = @group.name

        put :update, params: { id: @group,
          group: FactoryBot.attributes_for(:group, name: nil, description: "tester") }
        @group.reload
        expect(@group.description).not_to eq("tester")
        expect(@group.name).to eq(name)
      end

      it "re-renders the edit method" do
        put :update, params: { id: @group, group: FactoryBot.attributes_for(:invalid_group) }
        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE destroy' do
    before :each do
      @group = FactoryBot.create(:group)
    end

    it "deletes the group" do
      expect{
        delete :destroy, params: { id: @group }
      }.to change(UserGroup::Group,:count).by(-1)
    end
  end

  describe 'PUT lock' do
    before :each do
      @group = FactoryBot.create(:group)
    end

    it "locks the group" do
      expect(@group.is_locked?).to be_falsey

      put :lock, params: { id: @group }
      @group.reload
      expect(@group.is_locked?).to be true
    end

    it "unlocks the group" do
      @group.toggle_lock
      @group.save
      expect(@group.is_locked?).to be true

      put :lock, params: { id: @group }
      @group.reload
      expect(@group.is_locked?).to be_falsey
    end
  end

end
