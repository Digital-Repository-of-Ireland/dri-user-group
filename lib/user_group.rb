require "user_group/engine"

module UserGroup
    autoload :UserSecurity, 'user_group/user_security'
    autoload :UserOptions, 'user_group/user_options'
    autoload :SharedAbility, 'access_controls/shared_ability'
    autoload :PermissionsCheck, 'access_controls/permissions_check'
    autoload :InheritanceMethods, 'access_controls/inheritance_methods'
    autoload :SolrAccessControls, 'access_controls/solr_access_controls'
    autoload :PermissionsSolrDocOverride, 'access_controls/overrides/permissions_solr_doc_override'
    autoload :RightsMetadataDatastreamOverride, 'access_controls/overrides/rights_metadata_datastream_override'
    autoload :RightsMetadataModelMixinOverride, 'access_controls/overrides/rights_metadata_model_mixin_override'
end
