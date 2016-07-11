require 'spec_helper'

describe UserGroup::MembershipsController do

  before(:each) do
    @routes = UserGroup::Engine.routes

    @login_user = FactoryGirl.create(:admin)
    @login_user.confirm
    sign_in @login_user

    @user = FactoryGirl.create(:user)
    @user.confirm
    @group = FactoryGirl.create(:group)
  end

  describe 'POST create' do 
    it "creates a new membership" do 
      @request.env['HTTP_REFERER'] = "/groups/#{@group.id}"

      expect(@user.member?(@group.id)).to be_falsey

      post :create, { "membership" => { "user_id" => @user.id, "group_id" => @group.id } }

      @user.reload
      expect(@user.member?(@group.id)).to be true
    end

    it "should not join unknown group" do
      @request.env['HTTP_REFERER'] = "/groups/#{@group.id}"
 
      allow(controller).to receive(:render)
  
      expect(@user.member?(100)).to be_falsey

      post :create, { "membership" => { "user_id" => @user.id, "group_id" => 100 } }

      @user.reload
      expect(@user.member?(100)).to be_falsey
    end
  end

  describe 'DELETE destroy' do 
    it "deletes the membership" do
      @request.env['HTTP_REFERER'] = "/groups/#{@group.id}"
 
      @membership = @login_user.join_group(@group.id)
      @membership.approve_membership(@login_user.id)
      @membership.save

      @login_user.reload   
      expect(@login_user.member?(@group.id)).to be true

      delete :destroy, {id: @group, "membership" => { "user_id" => @login_user.id, "group_id" => @group.id } } 

      @login_user.reload
      expect(@login_user.member?(@group.id)).to be_falsey   
    end 
  end

  describe 'PUT approve' do
    it "approves a membership" do
      @request.env['HTTP_REFERER'] = "/groups/#{@group.id}"

      @membership = @user.join_group(@group.id)
      expect(@membership.approved?).not_to be true

      put :approve, id: @membership

      @membership.reload
      expect(@membership.approved?).to be true
    end
  end

end
