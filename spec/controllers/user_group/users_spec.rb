require 'spec_helper'

describe UserGroup::UsersController do

  before(:each) do
    @routes = UserGroup::Engine.routes
  end

  it "does not error when I sign in" do
    @user1 = FactoryGirl.find_or_create(:user)
    sign_in @user1
    get :index
    #assigns[:users].should include(@user1)
    response.should be_successful
    expect(response.status).to eq(200)
    expect(response).to render_template(:index)
  end

  it "does not error when I sign in as an admin" do
    @user1 = FactoryGirl.find_or_create(:admin)
    sign_in @user1
    get :index
    # should check for something unique to the admin role
    response.should be_successful
  end

  describe "GET #index" do
    it "populates an array of public users" do
      @admin = FactoryGirl.find_or_create(:admin)
      sign_in @admin

      user = FactoryGirl.build(:user)
      user.set_view_level("public")
      user.save

      get :index
      assigns[:users].should_not be_nil
      assigns[:users].should eq([user])
    end
  end

  describe "GET #new" do
    it "assigns a new user" do
      get :new

      assigns(:user).should_not be_nil
      assigns(:user).should be_kind_of(UserGroup::User)
    end
  end

  it "should create a new user and save it" do
    post :create
    response.should be_successful
  end
end
