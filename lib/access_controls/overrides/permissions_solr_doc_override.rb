require 'active_support/core_ext/string'
module UserGroup
  module PermissionsSolrDocOverride
    extend ActiveSupport::Concern

      included do
      end

      def parent_id
        key = 'isGovernedBy_ssim'
        #Temp line as string manipulation is currently required on the value
        return nil unless self[key].present?
        self[key]
      end

      def under_embargo?
        embargo_key = 'embargo_release_date_tesim'
        if self[embargo_key]
          embargo_date = Date.parse(self[embargo_key].split(/T/)[0])
          return embargo_date > Date.parse(Time.now.to_s)
        end
      end

      def is_published?
        key = 'status_ssi'
        if self[key].present?
          return self[key].first.downcase == "published"
        end
      end

  end
end
