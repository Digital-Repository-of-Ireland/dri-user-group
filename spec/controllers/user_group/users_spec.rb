require 'spec_helper'

describe 'Users' do

  before(:each) do
    @routes = UserGroup::Engine.routes
  end

  it "should create a new user object" do
    @user = UserGroup::UsersController.new
  end

  it "should test users" do
    @user1 = FactoryGirl.find_or_create(:user)
    get :index
    assigns[:users].should include(@user1)
    response.should be_successful
  end

end
