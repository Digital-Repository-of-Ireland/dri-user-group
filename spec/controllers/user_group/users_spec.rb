require 'spec_helper'

describe UserGroup::UsersController do

  before(:each) do
    @routes = UserGroup::Engine.routes
  end

  it "should create a new user object" do
    @user = UserGroup::UsersController.new
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

  it "should create a new user" do
    post :new
    response.should be_successful
  end

  it "should create a new user and save it" do
    post :create
    response.should be_successful
  end
end
