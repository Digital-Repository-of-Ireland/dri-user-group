require 'spec_helper'

describe UserGroup::MembershipsController do

  before(:each) do
    @routes = UserGroup::Engine.routes

    @login_user = FactoryGirl.create(:admin)
    @login_user.confirm!
    sign_in @login_user

    @user = FactoryGirl.create(:user)
    @user.confirm!
    @group = FactoryGirl.create(:group)
  end

  describe 'POST create' do 
    it "creates a new membership" do 
      @request.env['HTTP_REFERER'] = "/groups/#{@group.id}"

      @user.member?(@group.id).should be_false

      post :create, { "membership" => { "user_id" => @user.id, "group_id" => @group.id } }

      @user.reload
      @user.member?(@group.id).should be_true
    end

    it "should not join unknown group" do
      @request.env['HTTP_REFERER'] = "/groups/#{@group.id}"
 
      controller.stub(:render)
  
      @user.member?(100).should be_false

      post :create, { "membership" => { "user_id" => @user.id, "group_id" => 100 } }

      @user.reload
      @user.member?(100).should be_false
    end
  end

  describe 'DELETE destroy' do 
    it "deletes the membership" do
      @request.env['HTTP_REFERER'] = "/groups/#{@group.id}"
 
      @membership = @login_user.join_group(@group.id)
      @membership.approve_membership(@login_user.id)
      @membership.save

      @login_user.reload   
      @login_user.member?(@group.id).should be_true

      delete :destroy, {id: @group, "membership" => { "user_id" => @login_user.id, "group_id" => @group.id } } 

      @login_user.reload
      @login_user.member?(@group.id).should be_false   
    end 
  end

  describe 'PUT approve' do
    it "approves a membership" do
      @request.env['HTTP_REFERER'] = "/groups/#{@group.id}"

      @membership = @user.join_group(@group.id)
      @membership.approved?.should_not be_true

      put :approve, id: @membership

      @membership.reload
      @membership.approved?.should be_true
    end
  end 

  describe 'POST pending' do
    it "creates a new pending membership" do
      @request.env['HTTP_REFERER'] = "/groups/#{@group.id}"
      @user.member?(@group.id).should be_false
      @user.pending_member?(@group.id).should_not be_true

      post :pending, { "membership" => { "user_id" => @user.id, "group_id" => @group.id } }

      @user.reload
      @user.pending_member?(@group.id).should be_true
      end
  end

end
