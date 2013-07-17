require 'spec_helper'

describe UserGroup::UsersController do

  describe "Test Routing?" do
    it "POST #create" do
      post :create, :use_route => :user_group
    end

    it "POST #edit" do
      post :edit, :use_route => :user_group
    end

    it "GET #index" do
      get :index, :use_route => :user_group
    end

    it "GET #show" do
      #get :show, :use_route => :user_group
    end

  end

end
