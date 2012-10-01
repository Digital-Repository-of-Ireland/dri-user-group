class ApplicationController < ActionController::Base
  protect_from_forgery

#I really hope this keeps it away from the user
protected
    def admin_users
        if !current_user.is_admin?
            flash[:error] = "You must be an admin"
            redirect_to(root_url)
        end   
    end

    #Need a better check than email
    def modifying_current_user? (user_to_modify)
        return false unless current_user.email == user_to_modify.email
        return true
    end

    def can_modify_base(user_to_modify)
        if ! (current_user.is_admin? || modifying_current_user?(user_to_modify) )
            flash[:error] = "You do not have permission"
            redirect_to(root_url)
        end
        @user = user_to_modify
    end
end
