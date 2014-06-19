require 'spec_helper'

describe UserGroup do
  it "should create a valid user object" do
    @user = UserGroup::User.new
    @user.should_not be_valid

    @user.first_name = "FirstName"
    @user.second_name = "SecondName"
    @user.email = "FirstName.SecondName@host.domain"
    @user.password = "foobar"
    @user.password_confirmation = "foobar"
    @user.confirmed_at = Time.now
    @user.should be_valid
  end
end
