require 'spec_helper'

describe UserGroup::Group do

  before(:each) do
    @user = FactoryGirl.build(:user)
    @user.save
  end

  it "should create a valid group object" do
    @group = UserGroup::Group.new
    @group.should_not be_valid

    @group.name = "test"
    @group.description = "a test group"

    @group.should be_valid
  end

  it "should be toggleable" do
    @group = UserGroup::Group.new
    @group.toggle_lock.should be_true
    @group.toggle_lock.should_not be_true
  end

  it "should test full_memberships" do
    @group = UserGroup::Group.create(name: "test group", description: "a test group")
    @group.full_memberships.should be_empty

    @membership = @user.join_group(@group.id)    
    @membership.approved_by = @user.id
    @membership.save

    @group.full_memberships.should_not be_empty
  end

  it "should test pending_memberships" do
    @group = UserGroup::Group.create(name: "test group", description: "a test group")
    @group.pending_memberships.should be_empty

    @membership = @user.join_group(@group.id)
    @membership.save

    @group.pending_memberships.should_not be_empty
  end
end
