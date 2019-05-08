require 'active_support/core_ext/string'
module UserGroup
  module PermissionsSolrDocOverride
    extend ActiveSupport::Concern

      included do
      end

      def parent_id
        key = ActiveFedora.index_field_mapper.solr_name("isGovernedBy", :stored_searchable, type: :symbol)
        #Temp line as string manipulation is currently required on the value
        return nil unless self[key].present?
        return self[key]
      end

      def under_embargo?
        embargo_key = ActiveFedora.index_field_mapper.solr_name("embargo_release_date")
        if self[embargo_key]
          embargo_date = Date.parse(self[embargo_key].split(/T/)[0])
          return embargo_date > Date.parse(Time.now.to_s)
        end
        return nil
      end

      def is_published?
        key = ActiveFedora.index_field_mapper.solr_name('status', :stored_searchable, type: :symbol)
        if self[key].present?
          return self[key].first.downcase == "published"
        end
        return nil
      end

  end
end
