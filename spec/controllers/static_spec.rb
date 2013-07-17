require 'spec_helper'

describe UserGroup::StaticController do

  it "should GET #home" do
    { :get => 'user_group/home', :use_route => :user_group }.should route_to("user_group/static#home")
  end

end
