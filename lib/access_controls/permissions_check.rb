module UserGroup
  module PermissionsCheck
    def enforce_permissions!(action, item)
        logger.debug("[Enforce Permissions] - A: #{action} O: #{item.to_s}")

        case action
        when nil, "edit", "update"
          raise Hydra::AccessDenied.new(t('dri.flash.alert.edit_permission'), :edit, item) unless can? :edit, item
        when "create"
          raise Hydra::AccessDenied.new(t('dri.flash.alert.create_permission'), :create, item) unless can? :create, item
        when "show" #[view assets]
          #Embargo check? 
          raise Hydra::AccessDenied.new(t('dri.flash.alert.read_permission'), :read, item) unless can? :read, item
        when "show_digital_object"
          raise Hydra::AccessDenied.new("Document does not exist.", :read, item) if current_ability.permissions_doc(item).nil?
     
          #Embargo should come first
          if current_ability.get_permission_method(item,"under_embargo?") && cannot?(:edit, item)
            raise Hydra::AccessDenied.new("This item is under embargo. You do not have sufficient access privileges to read this document.", :edit, item)
          end

          if current_ability.get_permission_method(item,"is_private?")
            raise Hydra::AccessDenied.new("You do not have sufficient access privileges to read this document, which has been marked private.", :search, item) unless can? :search, item
          end
        
          if !current_ability.get_permission_method(item,"is_published?") && cannot?(:edit, item)
            raise Hydra::AccessDenied.new("You do not have sufficient access privileges to read this document, which is in draft mode.", :edit, item)
          end
        when "show_master"
          #Embargo check?
          raise Hydra::AccessDenied.new("This item is not available. You do not have sufficient access privileges to view the master file(s).", :read_master, item) unless can? :read_master, item
        when "manage_collection"
          #Should I change to manager? Only time this can happen is malicious or command line?
          raise Hydra::AccessDenied.new(t('dri.flash.alert.edit_permission'), :edit, item) unless can? :edit, item
        when "create_digital_object"
          raise Hydra::AccessDenied.new(t('dri.flash.alert.create_permission'), :create, "") unless can? :create_do,  item
        else
          raise Hydra::AccessDenied.new(t('dri.flash.alert.unknown_permission', :action => action), :read, item)
        end
      
    end

  end
end