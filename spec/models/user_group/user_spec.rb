require 'spec_helper'

describe UserGroup do
  it "should create a valid user object" do
    @user = User.new
    user.should_be valid
  end
end
