module UserGroup
  module SharedAbility
    extend ActiveSupport::Concern

    included do

    end

    attr_reader :current_user, :session, :cache

    def initialize(user, session=nil)
      @current_user = user || Hydra::Ability.user_class.new # guest user (not logged in)
      @user = @current_user # just in case someone was using this in an override. Just don't.
      @session = session
      @cache = Hydra::PermissionsCache.new
      #Default: Giving same level as edit
      alias_action :edit, :update, :destroy, :to => :manage_collection
      hydra_default_permissions()
    end

    #383 Modified
    ## You can override this method if you are using a different AuthZ (such as LDAP)
    def user_groups
      return @user_groups if @user_groups
      @user_groups = default_user_groups
      @user_groups |=  UserGroup::Group.find(current_user.full_memberships.pluck(:group_id)).map(&:name) if current_user and current_user.respond_to? :full_memberships
      @user_groups
    end

    def default_user_groups
      # # everyone is automatically a member of the group 'public'
      [SETTING_GROUP_PUBLIC]
    end


    def hydra_default_permissions
      logger.debug("Usergroups are " + user_groups.inspect)
      self.ability_logic.each do |method|
        send(method)
      end
    end


    protected

    def test_create(collection)
      return can? :edit, collection
    end

    def test_edit(pid)
      logger.debug("[CANCAN] Checking edit permissions for user: #{current_user.user_key} with groups: #{user_groups.inspect}")
      group_intersection = user_groups & edit_groups(pid)
      result = !group_intersection.empty? || edit_persons(pid).include?(current_user.user_key)
      logger.debug("[CANCAN] decision: #{result}")
      result
    end

    def test_read(pid)
      logger.debug("[CANCAN] Checking read permissions for user: #{current_user.user_key} with groups: #{user_groups.inspect}")
      group_intersection = user_groups & read_groups(pid)
      result = !group_intersection.empty? || read_persons(pid).include?(current_user.user_key)
      result
    end

    def test_search(pid)
      logger.debug("[CANCAN] Checking search permissions for user: #{current_user.user_key} with groups: #{user_groups.inspect}")
      group_intersection = user_groups & search_groups(pid)
      result = !group_intersection.empty? || search_persons(pid).include?(current_user.user_key)
    end

    def test_read_master(pid)
      #show master true -> test_read, if false, test_edit permission
      return get_permission_method(pid,"show_master_file?") ? test_read(pid) : test_edit(pid)
    end

    def test_manager(pid)
      logger.debug("[CANCAN] Checking manager permissions for user: #{current_user.user_key} with groups: #{user_groups.inspect}")
      group_intersection = user_groups & manager_groups(pid)
      result = !group_intersection.empty? || manager_persons(pid).include?(current_user.user_key)
    end

    #383 Modified. manager implies edit, so edit_groups is the union of manager and edit groups
    def edit_groups(pid)
      eg = manager_groups(pid) | ( get_permission_key(pid,self.class.edit_group_field) || [])
      logger.debug("[CANCAN] edit_groups: #{eg.inspect}")
      return eg
    end

    #edit implies read, so read_groups is the union of edit and read groups
    def read_groups(pid)
      rg = edit_groups(pid) | ( get_permission_key(pid,self.class.read_group_field) || [])
      logger.debug("[CANCAN] read_groups: #{rg.inspect}")
      return rg
    end

    #383 Modified. manager implies edit, so edit_persons is the union of manager and edit persons
    def edit_persons(pid)
      ep = manager_persons(pid) | ( get_permission_key(pid,self.class.edit_person_field) ||  [])
      logger.debug("[CANCAN] edit_persons: #{ep.inspect}")
      return ep
    end

    # edit implies read, so read_persons is the union of edit and read persons
    def read_persons(pid)
      rp = edit_persons(pid) | ( get_permission_key(pid,self.class.read_person_field) || [])
      logger.debug("[CANCAN] read_persons: #{rp.inspect}")
      return rp
    end

    #383 Addition. Managers are at the top level
    def manager_groups(pid)
      mg = get_permission_key(pid,self.class.manager_group_field) ||  []
      logger.debug("[CANCAN] manager_groups: #{mg.inspect}")
      return mg
    end

    #383 Addition
    def manager_persons(pid)
      mp = get_permission_key(pid,self.class.manager_person_field) ||  []
      logger.debug("[CANCAN] manager_persons: #{mp.inspect}")
      return mp
    end

    #383 Addition. A search group/person has access to a DO (but not the assets)
    def search_groups(pid)
      sg = read_groups(pid) | (get_permission_key(pid,self.class.search_group_field) ||  [])
      logger.debug("[CANCAN] search_groups: #{sg.inspect}")
      return sg
    end

    #383 Addition
    def search_persons(pid)
      sp = read_persons(pid) | (get_permission_key(pid,self.class.search_person_field) ||  [])
      logger.debug("[CANCAN] manager_persons: #{sp.inspect}")
      return sp
    end

    module ClassMethods
      def read_group_field
        Hydra.config[:permissions][:read][:group]
      end

      def edit_person_field
        Hydra.config[:permissions][:edit][:individual]
      end

      def read_person_field
        Hydra.config[:permissions][:read][:individual]
      end

      def edit_group_field
        Hydra.config[:permissions][:edit][:group]
      end

      #383 Addition
      def manager_group_field
        Hydra.config[:permissions][:manager][:group]
      end

      #383 Addition
      def manager_person_field
        Hydra.config[:permissions][:manager][:individual]
      end

      #383 Addition
      def search_group_field
        Hydra.config[:permissions][:discover][:group]
      end

      #383 Addition
      def search_person_field
        Hydra.config[:permissions][:discover][:individual]
      end
    end

  end
end
