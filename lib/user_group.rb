require "user_group/engine"

module UserGroup
    autoload :UserSecurity, 'user_group/user_security'
    autoload :UserOptions, 'user_group/user_options'
    autoload :Permissions, 'user_group/permissions'
    autoload :PermissionsCheck, 'user_group/permissions_check'
end
