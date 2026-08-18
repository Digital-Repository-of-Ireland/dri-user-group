module UserGroup
  module PermissionsCheck
    def enforce_permissions!(action, item)
      Rails.logger.debug("[Enforce Permissions] - A: #{action} O: #{item}")

      case action
      when nil, 'edit', 'update'
        unless can? :edit,
                    item
          raise Blacklight::AccessControls::AccessDenied.new(t('dri.flash.alert.edit_permission'), :edit,
                                                             item)
        end
      when 'create'
        unless can? :create,
                    item
          raise Blacklight::AccessControls::AccessDenied.new(t('dri.flash.alert.create_permission'), :create,
                                                             item)
        end
      when 'show' # [view assets]
        # Embargo check?
        unless can? :read,
                    item
          raise Blacklight::AccessControls::AccessDenied.new(t('dri.flash.alert.read_permission'), :read,
                                                             item)
        end
      when 'show_digital_object'
        if current_ability.permissions_doc(item).nil?
          raise Blacklight::AccessControls::AccessDenied.new('Document does not exist.', :read,
                                                             item)
        end

        # Embargo should come first
        if current_ability.get_permission_method(item, 'under_embargo?') && cannot?(:edit, item)
          raise Blacklight::AccessControls::AccessDenied.new(
            'This item is under embargo. You do not have sufficient access privileges to read this document.', :edit, item
          )
        end

        if current_ability.get_permission_method(item, 'is_private?') && !can?(:search,
                                                                               item)
          raise Blacklight::AccessControls::AccessDenied.new(
            'You do not have sufficient access privileges to read this document, which has been marked private.', :search, item
          )
        end

        doc = current_ability.permissions_doc(item)
        if !doc.parent_id.nil? && !current_ability.get_permission_method(doc.parent_id,
                                                                         'is_published?') && cannot?(:edit, item)
          raise Blacklight::AccessControls::AccessDenied.new(
            'You do not have sufficient access privileges to read this document, which is in draft mode.', :edit, item
          )
        end

        if !current_ability.get_permission_method(item, 'is_published?') && cannot?(:edit, item)
          raise Blacklight::AccessControls::AccessDenied.new(
            'You do not have sufficient access privileges to read this document, which is in draft mode.', :edit, item
          )
        end
      when 'manage_collection'
        # Should I change to manager? Only time this can happen is malicious or command line?
        unless can? :edit,
                    item
          raise Blacklight::AccessControls::AccessDenied.new(t('dri.flash.alert.edit_permission'), :edit,
                                                             item)
        end
      when 'create_digital_object'
        unless can? :create_do,
                    item
          raise Blacklight::AccessControls::AccessDenied.new(t('dri.flash.alert.create_permission'), :create,
                                                             '')
        end
      else
        raise Blacklight::AccessControls::AccessDenied.new(t('dri.flash.alert.unknown_permission', action: action),
                                                           :read, item)
      end
    end
  end
end
