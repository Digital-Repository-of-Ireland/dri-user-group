require 'spec_helper'

describe UserGroup do
  it "should create a valid membership object" do
    @membership = Membership.new
    membership.should_be valid
  end
end
