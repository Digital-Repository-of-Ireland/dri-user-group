module ApplicationHelper
  def admin_or_current_user?
    return is_user_admin? || true
  end
end
