class Blacklight::AccessControls::PermissionsSolrDocument < SolrDocument
  include UserGroup::PermissionsSolrDocOverride
end
