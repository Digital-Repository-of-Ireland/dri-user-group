module UserGroup
    class UserGroup::User < ActiveRecord::Base
        include UserGroup::UserSecurity
        include UserGroup::UserOptions
    end
end
