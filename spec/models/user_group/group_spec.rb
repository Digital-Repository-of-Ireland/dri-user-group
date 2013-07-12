require 'spec_helper'

describe UserGroup do
  it "should create a valid group object" do
    @group = Group.new
    group.should_be valid
  end
end
