module UserGroup
  module PermissionsCheck
    def enforce_permissions!(action, id_or_object)
        logger.debug("[Enforce Permission] - A: #{action} O: #{id_or_object.to_s}")
        #Do nothing
        #is_string = id_or_object.is_a? String

        id = id_or_object
        object = id_or_object
        debugger
        case action
        when nil, "edit", "update"
          raise Hydra::AccessDenied.new(t('dri.flash.alert.edit_permission'), :edit, id) unless can? :edit, id
        when "create"
          raise Hydra::AccessDenied.new(t('TODO'), :create, id) unless can? :create, id
        when "show"
          #[Embargo check? - what is show??] [ view assets]
          raise Hydra::AccessDenied.new(t('dri.flash.alert.read_permission'), :read, id) unless can? :read, id
        when "show_digital_object"
          logger.debug("[Enforce Permissions] Checking show_digital_object")
          doc = current_ability.permissions_doc(id)
          raise Hydra::AccessDenied.new("Document does not exist.", :read, id) if doc.nil?
     
          #Embargo should come first
          if doc.under_embargo? && cannot?(:edit, doc)
            raise Hydra::AccessDenied.new("This item is under embargo. You do not have sufficient access privileges to read this document.", :edit, id)
          end

          #WARNING: RETURNS FALSE if not set 
          #Should change this to get_solr_doc["private"]...
          if doc.is_private?
            #CHECK what happens with exception
            raise Hydra::AccessDenied.new("You do not have sufficient access privileges to read this document, which has been marked private.", :search, id) unless can? :search, doc
          end
        

          if !doc.is_published? && cannot?(:edit, doc)
            raise Hydra::AccessDenied.new("You do not have sufficient access privileges to read this document, which is in draft mode.", :edit, id)
          end
        when "show_master"
          #Embargo check?
          raise Hydra::AccessDenied.new("This item is not available. You do not have sufficient access privileges to view the master file(s).", :read_master, id) unless can? :read_master, id
        when "manage_collection"
          #Should I change to manager? Only time this can happen is malicious or command line?
          raise Hydra::AccessDenied.new(t('dri.flash.alert.edit_permission'), :edit, id) unless can? :edit, id
        when "create_digital_object"
          raise Hydra::AccessDenied.new(t('dri.flash.alert.create_permission'), :create, "") unless can? :create_do,  object
        else
          raise Hydra::AccessDenied.new(t('dri.flash.alert.unknown_permission', :action => action), :read, id)
        end
      
    end
  end
end