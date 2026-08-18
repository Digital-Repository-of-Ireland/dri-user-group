require 'active_support/concern'

module UserGroup
  module Helpers
    extend ActiveSupport::Concern

    def authenticate_user_from_token!
      user_email = params[:user].presence
      user = user_email && User.find_by_email(user_email)

      # Notice how we use Devise.secure_compare to compare the token
      # in the database with the token given in the params, mitigating
      # timing attacks.
      return unless user && Devise.secure_compare(user.authentication_token, params[:auth_token])

      sign_in user, store: false
    end
  end
end
