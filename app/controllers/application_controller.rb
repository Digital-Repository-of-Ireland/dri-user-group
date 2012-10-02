class ApplicationController < ActionController::Base
  protect_from_forgery

#I really hope this keeps it away from the user
protected
    def admin_users
        unless current_user.is_admin?
            flash[:error] = "You must be an admin"
            redirect_to(root_url)
        end   
    end

    def modifying_current_user? (user_to_modify)
        return false unless current_user.id == user_to_modify.id
        return true
    end

    def can_modify_base(user_to_modify)
        unless (current_user.is_admin? || modifying_current_user?(user_to_modify) )
            flash[:error] = "You do not have permission"
            redirect_to(root_url)
        end
        @user = user_to_modify
    end
end
