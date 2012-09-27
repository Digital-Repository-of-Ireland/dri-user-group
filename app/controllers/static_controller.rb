class StaticController < ApplicationController
  before_filter :authenticate_user!, only: [:admin] 
  before_filter :admin_users, only: [:admin]

  def home
  end

  def help
  end

  def admin
  end

  private
    def admin_users
        if !current_user.is_admin?
            flash[:error] = "You must be an admin"
            redirect_to(root_url)
        end
    end
end
