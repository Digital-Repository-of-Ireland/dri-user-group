# frozen_string_literal: true

module UserGroup
  class ApplicationController < ::ApplicationController
    # protect_from_forgery
    before_action :authenticate_user!

    protected

    def admin_users
      return unless signed_in

      return if current_user.is_admin?

      flash[:error] = I18n.t('user_groups.application.errors.admin')
      redirect_to(main_app.root_url)
    end

    def collection_mgr_users
      return unless signed_in

      return if current_user.is_om? || current_user.is_cm? || current_user.is_admin?

      flash[:error] = I18n.t('user_groups.application.errors.permission')
      redirect_to(main_app.root_url)
    end

    def modifying_current_user?(user_to_modify)
      return false unless current_user.id == user_to_modify.id

      true
    end

    def can_modify_base?(user_id)
      logger.debug "[TEMP] can_modify_base called on user_id: #{user_id}"
      user_to_modify = User.find_by_id(user_id)
      if user_to_modify.nil?
        flash[:error] = I18n.t('user_groups.shared.errors.user')
        redirect_to main_app.root_url
        return
      end

      return unless signed_in

      unless current_user.is_admin? || modifying_current_user?(user_to_modify)
        flash[:error] = I18n.t('user_groups.application.errors.permission')
        redirect_to main_app.root_url
        return
      end
      @user = user_to_modify
    end

    def signed_in
      unless current_user && user_signed_in?
        flash[:error] = I18n.t('devise.failure.unauthenticated')
        redirect_to user_group.new_user_session_path
        return false
      end
      true
    end
  end
end
