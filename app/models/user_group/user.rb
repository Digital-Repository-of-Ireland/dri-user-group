# TODO: Fix http://stackoverflow.com/questions/3356742/best-way-to-load-module-class-from-lib-folder-in-rails-3
require 'user_group/user_security'

module UserGroup
    class User < ActiveRecord::Base
        include UserGroup::UserSecurity
    end
end