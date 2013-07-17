require 'spec_helper'


describe UserGroup::StaticController do

  before(:each) { @routes = UserGroup::Engine.routes }

  it "should GET #home" do
    { :get => :users, :use_route => :user_group }.should be_routable
  end

end
