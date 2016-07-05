require 'spec_helper'

describe UserGroup::UsersController do

  before(:each) do
    @routes = UserGroup::Engine.routes

    allow(controller).to receive(:new_user_session_url)
  end

  describe "GET #index" do
    it "populates an array of public users" do
      @login_user = FactoryGirl.create(:user)
      @login_user.confirm
      sign_in @login_user
      
      user = FactoryGirl.create(:user)
      user.set_view_level("public")
      user.save
      user.confirm

      get :index
      assigns[:users].should_not be_nil
      expect(assigns[:users]).to match_array([user])
    end

    it "should not show private users" do
      @login_user = FactoryGirl.create(:user)
      @login_user.confirm
      sign_in @login_user

      user = FactoryGirl.create(:user)
      user.confirm

      get :index
      assigns[:users].should be_empty
    end

    it "should show all users to admin" do
      @login_user = FactoryGirl.create(:admin)
      @login_user.confirm
      sign_in @login_user

      private_user = FactoryGirl.create(:user)
      private_user.confirm
      public_user = FactoryGirl.create(:user)
      public_user.set_view_level("public")
      public_user.save
      public_user.confirm

      get :index
      assigns[:users].should_not be_nil
      expect(assigns[:users]).to match_array([@login_user, private_user, public_user])
    end
  end

  describe "GET #new" do
    it "assigns a new user" do
      get :new

      assigns(:user).should_not be_nil
      assigns(:user).should be_kind_of(UserGroup::User)
    end
  end

  describe "GET #show" do 
    it "renders the #show view" do 
      @login_user = FactoryGirl.create(:user)
      @login_user.confirm
      sign_in @login_user   
   
      get :show, id: @login_user 
      response.should render_template :show 
    end 
  end

  describe "POST create" do 
    context "with valid attributes" do 
      it "creates a new user" do 
        expect{ 
          post :create, user: FactoryGirl.attributes_for(:user) 
        }.to change(UserGroup::User,:count).by(1) 
      end

      #it "redirects to the new contact" do 
      #  post :create, user: FactoryGirl.attributes_for(:user) 
      #  response.should redirect_to UserGroup::User.last 
      #end
    end

    context "with invalid attributes" do 
      it "does not save the new user" do 
        expect{ 
          post :create, user: FactoryGirl.attributes_for(:invalid_user) 
        }.to_not change(UserGroup::User,:count) 
      end

      it "re-renders the new method" do 
        post :create, user: FactoryGirl.attributes_for(:invalid_user) 
        response.should render_template :new 
      end
    end
  end

  describe 'PUT update' do 
    before :each do 
      @user = FactoryGirl.create(:user) 
      @user.confirm
      sign_in @user
    end 

    context "valid attributes" do 
      it "located the requested @user" do 
        put :update, id: @user, 
        user: FactoryGirl.attributes_for(:user, current_password: "password") 
        assigns(:user).should eq(@user) 
      end 

      it "changes @user's attributes" do 
        put :update, id: @user,
          user: FactoryGirl.attributes_for(:user, first_name: "Jane", second_name: "Tester", current_password: "password")
        @user.reload 
        @user.first_name.should eq("Jane") 
        @user.second_name.should eq("Tester") 
      end 

      it "redirects to the updated user" do 
        put :update, id: @user, user: FactoryGirl.attributes_for(:user, current_password: "password") 
        response.should redirect_to @user 
      end 
    end

    context "invalid attributes" do
      it "does not change @user's attributes" do
        second_name = @user.second_name

        put :update, id: @user,
          user: FactoryGirl.attributes_for(:user, first_name: "Jane", second_name: nil, current_password: "password")
        @user.reload
        @user.first_name.should_not eq("Jane")
        @user.second_name.should eq(second_name)
      end

      it "re-renders the edit method" do
        put :update, id: @user, user: FactoryGirl.attributes_for(:invalid_user, current_password: "password")
        response.should render_template :edit
      end
    end
  end
    
  describe 'DELETE destroy' do 
    before :each do 
      @admin = FactoryGirl.create(:admin) 
      @admin.confirm
      sign_in @admin
    end 
  
   it "deletes the user" do
     @user = FactoryGirl.create(:user)
     @user.confirm
     expect{ 
       delete :destroy, id: @user 
     }.to change(UserGroup::User,:count).by(-1) 
   end 
 end

  describe 'tokens' do
    before :each do
      @user = FactoryGirl.create(:user)
      @user.confirm
      sign_in @user
    end

    it "creates a token" do
      post :create_token, id: @user
      @user.reload
      @user.authentication_token.should_not be_nil
    end

    it "deletes a token" do
      @user.create_token
      @user.save
      @user.authentication_token.should_not be_nil

      delete :destroy_token, id: @user
      @user.reload
      @user.authentication_token.should be_nil
    end
  end

end
