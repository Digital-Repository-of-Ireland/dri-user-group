require 'spec_helper'

describe 'Users' do

  before(:each) do
    @routes = UserGroup::Engine.routes
  end

  it "should create a new user object" do
    @user = UserGroup::UsersController.new
  end

end
