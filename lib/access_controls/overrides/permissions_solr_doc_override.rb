require 'active_support/core_ext/string'
module UserGroup
  module PermissionsSolrDocOverride
    extend ActiveSupport::Concern

      included do
      end

      #Method not finished
      def parent_id
        #This has to be added to solr as parent_id
        #key = "parent_id"
        key = ActiveFedora::SolrQueryBuilder.solr_name("is_governed_by")
        #Temp line as string manipulation is currently required on the value
        return nil unless self[key].present?
        return self[key].first.split("/").second
      end

      def under_embargo?
        embargo_key = ActiveFedora::SolrQueryBuilder.solr_name("embargo_release_date")
        if self[embargo_key]
          embargo_date = Date.parse(self[embargo_key].split(/T/)[0])
          return embargo_date > Date.parse(Time.now.to_s)
        end
        return nil
      end

      def is_published?
        key = ActiveFedora::SolrQueryBuilder.solr_name('status')
        if self[key].present?
          return self[key].first.downcase == "published"
        end
        return nil
      end

  end
end
