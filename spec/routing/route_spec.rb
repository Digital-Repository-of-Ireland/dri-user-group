require 'spec_helper'

describe 'Routes' do
  before(:each) do
    @routes = UserGroup::Engine.routes
    assertion_instance.instance_variable_set(:@routes, @routes)
  end

  describe "users" do
    it "POST #create" do
      { post: "/users" }.should be_routable
    end
  end

  describe "static pages" do
    it "should GET #home" do
      { get: "/home" }.should route_to(controller: 'user_group/static', action: 'home')
    end
  end

end
