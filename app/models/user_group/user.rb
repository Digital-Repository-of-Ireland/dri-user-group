module UserGroup
    class User < ActiveRecord::Base
        include UserGroup::UserSecurity
        include UserGroup::UserOptions
    end
end