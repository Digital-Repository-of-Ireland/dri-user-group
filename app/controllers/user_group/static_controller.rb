require_dependency 'user_group/application_controller'

module UserGroup
  class StaticController < ApplicationController
    before_action :authenticate_user!
    before_action :admin_users, only: [:admin]

    def home; end

    def help; end

    def admin; end
  end
end
