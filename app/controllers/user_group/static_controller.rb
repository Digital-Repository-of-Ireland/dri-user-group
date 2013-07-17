require_dependency "user_group/application_controller"

module UserGroup
    class StaticController < ApplicationController
      before_filter :authenticate_user!, only: [:admin]
      before_filter :admin_users, only: [:admin]

      def home
      end

      def help
      end

      def admin
      end
    end
end
