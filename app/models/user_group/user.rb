# TODO: Fix http://stackoverflow.com/questions/3356742/best-way-to-load-module-class-from-lib-folder-in-rails-3
require 'user_group/user_security'
require 'user_group/user_options'

module UserGroup
    class User < ActiveRecord::Base
        include UserGroup::UserSecurity
        include UserGroup::UserOptions
    end
end