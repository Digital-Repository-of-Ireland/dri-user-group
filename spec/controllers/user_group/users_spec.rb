require 'spec_helper'

describe UserGroup::UsersController do

    before(:each) { @routes = UserGroup::Engine.routes }

    it "POST #create" do
      { :post => :users, :use_route => :user_group }.should be_routable
    end

    it "POST #edit" do
      { :get => :edit_user, :use_route => :user_group }.should be_routable
    end

    it "GET #index" do
      { :get => :users, :use_route => :user_group }.should be_routable
    end

end
