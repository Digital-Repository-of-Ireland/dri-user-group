module UserGroup
  module SolrAccessControls
    extend ActiveSupport::Concern

    included do
      class_attribute :solr_access_filters_logic
      self.solr_access_filters_logic = [:apply_role_permissions, :apply_individual_permissions ]
    end

    protected

    def add_access_controls_to_solr_params(solr_parameters, user_parameters)
      apply_gated_discovery(solr_parameters, user_parameters)
    end

    def apply_gated_discovery(solr_parameters, user_parameters)
      
      solr_parameters[:fq] ||= []
      
      # Should be able to see published records
      # Filter for published objects that with published parents   
      governed_objects = "(" + ActiveFedora::SolrService.solr_name("is_governed_by", :symbol) + ":[* TO *]" +
           " AND (" + ActiveFedora::SolrService.solr_name("status", :symbol) + ":published" +
           " AND _query_:\"{!join from=id to=governing_id_sim}" + ActiveFedora::SolrService.solr_name("status", :symbol) + ":published\"))"

      # Filter for published objects
      objects = "(-" + ActiveFedora::SolrService.solr_name("is_governed_by", :symbol) + ":[* TO *]" +
           " AND " + ActiveFedora::SolrService.solr_name("status", :symbol) + ":published)"

      filter_published = governed_objects + " OR " + objects

      # Or any models that the user can edit or manage
      solr_parameters[:fq] << "(" + filter_published + 
                   ") OR (" + manager_and_edit_filter + 
                   ")" unless (current_user && current_user.is_admin?)

    end

    def gated_discovery_filters
      # Grant access to public content
      permission_types = discovery_permissions
      user_access_filters = []

      permission_types.each do |type|
        user_access_filters << ActiveFedora::SolrService.solr_name("#{type}_access_group", Hydra::Datastream::RightsMetadata.indexer) + ":public"
      end

      # Grant access based on user id & role
      solr_access_filters_logic.each do |method_name|
        user_access_filters += send(method_name, permission_types)
      end
      user_access_filters
    end

    def published_filter
      ActiveFedora::SolrService.solr_name("status", :symbol) + ":published"
    end

    def published_or_permitted_filter
      published_filter + " OR " + manager_and_edit_filter
    end

    def manager_and_edit_filter
      generate_permission_filters(["manager","edit"]).join(" OR ")
    end

    def generate_permission_filters(permission_types=["discover", "manager", "edit", "read"])
      filters = []
    
      user_roles = current_ability.user_groups
      user_roles |= ['public']

      string_user_roles = "("+user_roles.join(" OR ")+")"

      permission_types.each do |type|
        permission_query = escape_filter(ActiveFedora::SolrService.solr_name("#{type}_access_group", Hydra::Datastream::RightsMetadata.indexer), string_user_roles)

        if current_user && current_user.user_key.present?
          permission_query += " OR " + escape_filter(ActiveFedora::SolrService.solr_name("#{type}_access_person", Hydra::Datastream::RightsMetadata.indexer), current_user.user_key)
        end
        
        if type == "manager" || type == "edit"
          permission_query = "_query_:\"{!join from=id to=governing_id_sim}" + permission_query + "\" OR " +
                               "("+permission_query+")"
        elsif type == "discover"
          permission_query = "(" + ActiveFedora::SolrService.solr_name("private_metadata", Hydra::Datastream::RightsMetadata.integer_indexer) + ":0 OR " +
                             "(" + ActiveFedora::SolrService.solr_name("private_metadata", Hydra::Datastream::RightsMetadata.integer_indexer) + ":\"-1\" AND " +
         "_query_:\"{!join from=id to=governing_id_sim}" + ActiveFedora::SolrService.solr_name("private_metadata", Hydra::Datastream::RightsMetadata.integer_indexer) + ":0 OR " +
          "(" + ActiveFedora::SolrService.solr_name("private_metadata", Hydra::Datastream::RightsMetadata.integer_indexer) + ":1 AND (" + permission_query + "))\") OR " +
                             "(" + ActiveFedora::SolrService.solr_name("private_metadata", Hydra::Datastream::RightsMetadata.integer_indexer) + ":1 AND " +
                             "(" + permission_query + ")))"
        else
          permission_query = "((" + escape_filter(ActiveFedora::SolrService.solr_name("#{type}_access_inherit", Hydra::Datastream::RightsMetadata.indexer), "true") + " AND " +
                             "_query_:\"{!join from=id to=governing_id_sim}" + permission_query + "\" ) OR " + 
                             "(" + escape_filter(ActiveFedora::SolrService.solr_name("#{type}_access_inherit", Hydra::Datastream::RightsMetadata.indexer), "false") + " AND " +
                             "("+permission_query+")))"
         end

       filters << permission_query
      end

      filters
    end

    def apply_role_permissions(permission_types)
      # for roles
      user_access_filters = []
      current_ability.user_groups.each_with_index do |role, i|
        permission_types.each do |type|
          user_access_filters << escape_filter(ActiveFedora::SolrService.solr_name("#{type}_access_group", Hydra::Datastream::RightsMetadata.indexer), role)
        end
      end
      user_access_filters
    end

    def apply_individual_permissions(permission_types)
      # for individual person access
      user_access_filters = []
      if current_user && current_user.user_key.present?
        permission_types.each do |type|
          user_access_filters << escape_filter(ActiveFedora::SolrService.solr_name("#{type}_access_person", Hydra::Datastream::RightsMetadata.indexer), current_user.user_key)
        end
      end
      user_access_filters
    end

    def discovery_permissions
      @discovery_permissions ||= ["manager","edit","read","discover"]
    end

    def discovery_permissions= (permissions)
      @discovery_permissions = permissions
    end

    def escape_filter(key, value)
      [key, value.gsub('/', '\/')].join(':')
    end

    # This filters out objects that you want to exclude from search results.  By default it only excludes FileAssets
    # @param solr_parameters the current solr parameters
    # @param user_parameters the current user-subitted parameters
    def exclude_unwanted_models(solr_parameters, user_parameters)
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "-#{ActiveFedora::SolrService.solr_name("has_model", :symbol)}:\"info:fedora/afmodel:FileAsset\""
    end

  end
end
