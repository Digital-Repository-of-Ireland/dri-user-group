require 'spec_helper'

describe UserGroup::UserSecurity do
  before :each do
    @user_email = "text@example.com"
    @user_fname = "fname"
    @user_sname = "sname"
    @user_locale = "en"
    @user_password = "password"
    @user = UserGroup::User.create(:email => @user_email, :password => @user_password, :password_confirmation => @user_password, :locale => @user_locale, :first_name => @user_fname, :second_name => @user_sname)
    @user.skip_confirmation! 
  end
        
  #User security additions
  describe "#full_name" do
    it "should return the users name" do
      @user.full_name.should == @user_fname+" "+@user_sname
    end
  end

  describe "#is_admin?" do
    context "is an admin" do
      before :each do
        group_admin = UserGroup::Group.create(name: SETTING_GROUP_ADMIN, description: "admin group")
        group_id = group_admin.id
        membership = @user.join_group(group_id)
        membership.approved_by = @user.id
        membership.save
      end

      it "should return true" do
        @user.is_admin?.should == true
      end
    end

    context "not an admin" do
      it "should not be true" do
        @user.is_admin?.should be_falsey
      end
    end
  end

  describe "#member?" do
    before :each do
      @group = UserGroup::Group.create(name: "test group", description: "test group")
      @membership = @user.join_group(@group.id)
      @membership.approved_by = @user.id
      @membership.save 
    end
    
    context "valid member" do
      it "should be a member of the group" do
        @user.member?(@group.id).should == true    
      end

      it "should not be a pending member of the group" do
        @user.pending_member?(@group.id).should be_falsey
      end
    end
  end

  describe "#pending_member?" do
    before :each do
      @group = UserGroup::Group.create(name: "test group", description: "test group")
      @membership = @user.join_group(@group.id)
    end

    context "pending member" do
      it "should be a pending member of the group" do
        @user.pending_member?(@group.id).should == true
      end

      it "should not be a member of the group" do
        @user.member?(@group.id).should be_falsey
      end
    end        
  end

  describe "#join_group" do
    context "group exists" do
      before :each do
        @group = UserGroup::Group.create(name: "test group", description: "test group")
      end

      it "should return a valid (pending) membership" do
        membership = @user.join_group(@group.id)
        membership.valid?.should == true
        @user.pending_member?(@group.id).should == true
      end
    end

    context "invalid group" do
      it "should return an invalid membership" do
        membership = @user.join_group(nil)
        membership.valid?.should be_falsey
      end
    end
  end

  describe "#leave_group" do
    before :each do
      @group = UserGroup::Group.create(name: "test group", description: "test group")
      @membership = @user.join_group(@group.id) 
    end

    context "leaving a group with full membership" do
      before :each do
        @membership.approved_by = @user.id
        @membership.save
        @user.member?(@group.id).should == true
      end

      it "should remove the user from the group" do
        @user.leave_group(@group.id)
        @user.member?(@group_id).should be_falsey and @user.pending_member?(@group.id).should be_falsey
      end  
    end

    context "leave a group with partial membership" do
       before :each do
         @user.pending_member?(@group.id).should == true
       end

       it "should remove the user from the group" do
         @user.leave_group(@group.id)
         @user.member?(@group_id).should be_falsey and @user.pending_member?(@group.id).should be_falsey
       end
    end
  end

  describe "#create_token" do
    before :each do
      @user.authentication_token = nil
      @user.token_creation_date = nil
    end
  
    it "should create a login token" do
       @user.authentication_token.should be_nil
       @user.create_token
       @user.authentication_token.empty?.should be_falsey
    end
  end

   describe "#destroy_token" do
     before :each do
       @user.create_token
     end
 
     it "should delete the login token" do
       @user.authentication_token.should_not be_nil
       @user.token_creation_date.should_not be_nil

       @user.destroy_token

       @user.authentication_token.should be_nil
       @user.token_creation_date.should be_nil
     end
        end

  describe "#full_memberships" do
    before :each do
      @group = UserGroup::Group.create(name: "test group", description: "test group")
      @membership = @user.join_group(@group.id)
      @membership.approved_by = @user.id
      @membership.save

      @groupb = UserGroup::Group.create(name: "test group b", description: "test group b")
      @membershipb = @user.join_group(@groupb.id)
    end
   
    context "full memberships" do

      it "should be a full member of group a" do
        @user.full_memberships.map(&:group_id).include?(@group.id).should ==  true                    
      end

      it "should not be a full member of group b" do
         @user.full_memberships.map(&:group_id).include?(@groupb.id).should == false
      end
     end
  end

  describe "#pending_memberships" do
    before :each do
      @group = UserGroup::Group.create(name: "test group", description: "test group")
      @membership = @user.join_group(@group.id)
      @membership.approved_by = @user.id
      @membership.save

      @groupb = UserGroup::Group.create(name: "test group b", description: "test group b")
      @membershipb = @user.join_group(@groupb.id)
    end
   
    context "pending memberships" do
  
      it "should not be a pending member of group a" do
        @user.pending_memberships.map(&:group_id).include?(@group.id).should == false                    
      end

      it "should be a pending member of group b" do
        @user.pending_memberships.map(&:group_id).include?(@groupb.id).should == true
      end
    end
  end

end
