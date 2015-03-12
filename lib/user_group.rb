require "user_group/engine"

module UserGroup
    autoload :Helpers, 'user_group/helpers'
    autoload :UserSecurity, 'user_group/user_security'
    autoload :UserOptions, 'user_group/user_options'
    autoload :SharedAbility, 'access_controls/shared_ability'
    autoload :PermissionsCheck, 'access_controls/permissions_check'
    autoload :InheritanceMethods, 'access_controls/inheritance_methods'
    autoload :PermissionsSolrDocOverride, 'access_controls/overrides/permissions_solr_doc_override'
    autoload :PermissionOverride, 'access_controls/overrides/permission_override'
end
