require 'spec_helper'

describe UserGroup::Membership do
  it "should create a membership object" do
    @membership = UserGroup::Membership.new
    expect(@membership).not_to be_valid
  end

  it "should be approved" do
    @membership = UserGroup::Membership.new
    expect(@membership).not_to be_valid

    @membership.approve_membership('notadmin@host.domain')
    expect(@membership).not_to be_valid

    expect(@membership.approved?).to be true
  end

  it "should not be approved" do
    @membership = UserGroup::Membership.new
    expect(@membership).not_to be_valid

    expect(@membership.approved?).not_to be true
  end

end

