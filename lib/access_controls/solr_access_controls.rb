module UserGroup
  module SolrAccessControls
    extend ActiveSupport::Concern

    included do
      class_attribute :solr_access_filters_logic
      self.solr_access_filters_logic = [:apply_role_permissions, :apply_individual_permissions ]  
    end

    protected

    def add_public_head_access_controls_to_solr_params(solr_parameters, user_parameters)
      apply_public_gated_discovery(solr_parameters,user_parameters)
    end

    def add_admin_head_access_controls_to_solr_params(solr_parameters, user_parameters)
      apply_admin_gated_discovery(solr_parameters,user_parameters)
    end

    # Contrller before filter that sets up access-controlled lucene query in order to provide gated discovery behavior
    # @param solr_parameters the current solr parameters
    # @param user_parameters the current user-subitted parameters
    def apply_public_gated_discovery(solr_parameters, user_parameters)
      solr_parameters[:fq] ||= []
      #This line does NOT work...properties_status_ssm:published doesn't return anything
      filter_published =  ActiveFedora::SolrService.solr_name("properties_status", Hydra::Datastream::RightsMetadata.not_indexed_indexer) + ":published"+ " AND (" + ActiveFedora::SolrService.solr_name("private_metadata", Hydra::Datastream::RightsMetadata.integer_indexer) + ":0 " + " OR "

      solr_parameters[:fq] << filter_published+gated_discovery_filters.join(" OR ")+" ) "
      logger.debug("Solr parameters: #{ solr_parameters.inspect }")
    end 

    #Admin head should only show content that I have access to
    def apply_admin_gated_discovery(solr_parameters, user_parameters)
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << gated_discovery_filters.join(" OR ")
      logger.debug("Solr parameters: #{ solr_parameters.inspect }")
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
    def disocvery_permissions= (permissions)
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