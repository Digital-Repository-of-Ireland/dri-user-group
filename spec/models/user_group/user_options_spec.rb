require 'spec_helper'

describe UserGroup::UserOptions do
  before :each do
    @user = FactoryGirl.build(:user)
  end

  describe "#set_locale" do
    before :each do
      @user.locale = ""
    end
    
    it "should reset locale to default" do
      @user.locale.should == ""
      @user.set_locale
      @user.locale.should == I18n.locale
    end
  end

  describe "#set_view_level" do
    before :each do
      @user.view_level = 0
    end
    
    it "should set view level to public (1)" do
      @user.view_level.should == 0
      @user.set_view_level("public")
      @user.view_level.should == 1
    end
  end

  describe "#get_view_level" do
    before :each do
      @user.set_view_level("registered")
    end

    it "should return registered" do
      @user.get_view_level.should == "registered"
    end
  end
  
end
