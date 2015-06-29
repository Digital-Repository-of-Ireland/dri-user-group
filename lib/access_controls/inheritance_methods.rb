module UserGroup
  module InheritanceMethods

    def get_permission_key(pid, key)
      Rails.logger.debug("[Get Permission Key] - #{pid}:#{key}")
      return nil if pid.nil? or key.nil?

      begin
        doc = permissions_doc(pid)
      rescue Blacklight::Exceptions::InvalidSolrID
        return nil
      end

      return nil if doc.nil?
      return doc[key] if doc[key].present?
      return get_permission_key(doc.parent_id,key)
    end

    def get_permission_method(pid,method_name)
      Rails.logger.debug("[Get Permission Method] - #{pid}:#{method_name}")
      return nil if pid.nil? or method_name.nil?

      begin
        doc = permissions_doc(pid)
      rescue Blacklight::Exceptions::InvalidSolrID
        return nil
      end

      #A way of ensuring only certain methods can be called
      if doc.respond_to? method_name  and ["is_public?","is_private?","under_embargo?","is_published?"].include? method_name
        result = doc.send(method_name)
        return result unless result.nil?

        return get_permission_method(doc.parent_id,method_name)
      end

      Rails.logger.debug("[Get Permission Method] - Method denied or doesnt exist")
      return nil
    end
  end
end
