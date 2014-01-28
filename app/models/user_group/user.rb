module UserGroup
  class UserGroup::User < ActiveRecord::Base
    include UserGroup::UserSecurity
    include UserGroup::UserOptions

    def self.create_for_shibboleth(access_token)
      u = UserGroup::User.new
      u.apply_omniauth(access_token)
      u
    end

  end
end
