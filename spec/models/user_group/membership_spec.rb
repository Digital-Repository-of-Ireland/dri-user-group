require 'spec_helper'

describe UserGroup::Membership do
  it "should create a membership object" do
    @membership = UserGroup::Membership.new
    @membership.should_not be_valid
  end

  it "should be approved" do
    @membership = UserGroup::Membership.new
    @membership.should_not be_valid

    @membership.approve_membership('notadmin@host.domain')
    @membership.should_not be_valid

    @membership.approved?.should be_true
  end

  it "should not be approved" do
    @membership = UserGroup::Membership.new
    @membership.should_not be_valid

    @membership.approved?.should_not be_true
  end

end

