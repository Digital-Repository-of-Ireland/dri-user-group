require 'spec_helper'

describe UserGroup::Group do
  it "should create a valid group object" do
    @group = UserGroup::Group.new
    @group.should_not be_valid
  end

  it "should be toggleable" do
    @group = UserGroup::Group.new
    @group.toggle_lock.should be_true
    @group.toggle_lock.should_not be_true
  end

#  it "should test full_memberships" do
#    @group = UserGroup::Group.new
#    @group.full_memberships.should be_empty
#  end
#
#  it "should test pending_memberships" do
#    @group = UserGroup::Group.new
#    @group.pending_memberships.should be_empty
#  end
end
