module UserGroup
  module SharedAbility
    extend ActiveSupport::Concern

    included do
      include CanCan::Ability
    end

    attr_reader :current_user, :session, :cache

    def initialize(user, session = nil)
      @current_user = user || Blacklight::AccessControls::Ability.user_class.new # guest user (not logged in)
      @user = @current_user # just in case someone was using this in an override. Just don't.
      @session = session
      @cache = Blacklight::AccessControls::PermissionsCache.new
      # Default: Giving same level as edit
      alias_action :edit, :update, :destroy, to: :manage_collection
      default_permissions
    end

    # 383 Modified
    ## You can override this method if you are using a different AuthZ (such as LDAP)
    def user_groups
      return @user_groups if @user_groups

      @user_groups = default_user_groups
      if current_user and current_user.respond_to? :full_memberships
        @user_groups |= UserGroup::Group.find(current_user.full_memberships.pluck(:group_id)).map(&:name)
      end
      @user_groups
    end

    def default_user_groups
      # # everyone is automatically a member of the group 'public'
      [SETTING_GROUP_PUBLIC]
    end

    def default_permissions
      Rails.logger.debug('Usergroups are ' + user_groups.inspect)
      ability_logic.each do |method|
        send(method)
      end
    end

    protected

    def test_create(collection)
      can? :edit, collection
    end

    def test_edit(pid)
      Rails.logger.debug("[CANCAN] Checking edit permissions for user: #{current_user.user_key} with groups: #{user_groups.inspect}")
      group_intersection = user_groups & edit_groups(pid)
      result = !group_intersection.empty? || edit_users(pid).include?(current_user.user_key)
      Rails.logger.debug("[CANCAN] decision: #{result}")
      result
    end

    def test_read(pid)
      Rails.logger.debug("[CANCAN] Checking read permissions for user: #{current_user.user_key} with groups: #{user_groups.inspect}")
      group_intersection = user_groups & read_groups(pid)
      !group_intersection.empty? || read_users(pid).include?(current_user.user_key)
    end

    def test_search(pid)
      Rails.logger.debug("[CANCAN] Checking search permissions for user: #{current_user.user_key} with groups: #{user_groups.inspect}")
      group_intersection = user_groups & search_groups(pid)
      !group_intersection.empty? || search_users(pid).include?(current_user.user_key)
    end

    def test_manager(pid)
      Rails.logger.debug("[CANCAN] Checking manager permissions for user: #{current_user.user_key} with groups: #{user_groups.inspect}")
      group_intersection = user_groups & manager_groups(pid)
      !group_intersection.empty? || manager_users(pid).include?(current_user.user_key)
    end

    # 383 Modified. manager implies edit, so edit_groups is the union of manager and edit groups
    def edit_groups(pid)
      eg = manager_groups(pid) | (get_permission_key(pid, self.class.edit_group_field) || [])
      Rails.logger.debug("[CANCAN] edit_groups: #{eg.inspect}")
      eg
    end

    # edit implies read, so read_groups is the union of edit and read groups
    def read_groups(pid)
      rg = edit_groups(pid) | (get_permission_key(pid, self.class.read_group_field) || [])
      Rails.logger.debug("[CANCAN] read_groups: #{rg.inspect}")
      rg
    end

    # 383 Modified. manager implies edit, so edit_persons is the union of manager and edit persons
    def edit_users(pid)
      ep = manager_users(pid) | (get_permission_key(pid, self.class.edit_user_field) || [])
      Rails.logger.debug("[CANCAN] edit_users: #{ep.inspect}")
      ep
    end

    # edit implies read, so read_persons is the union of edit and read persons
    def read_users(pid)
      rp = edit_users(pid) | (get_permission_key(pid, self.class.read_user_field) || [])
      Rails.logger.debug("[CANCAN] read_users: #{rp.inspect}")
      rp
    end

    # 383 Addition. Managers are at the top level
    def manager_groups(pid)
      mg = get_permission_key(pid, self.class.manager_group_field) || []
      Rails.logger.debug("[CANCAN] manager_groups: #{mg.inspect}")
      mg
    end

    # 383 Addition
    def manager_users(pid)
      mp = get_permission_key(pid, self.class.manager_user_field) || []
      Rails.logger.debug("[CANCAN] manager_users: #{mp.inspect}")
      mp
    end

    # 383 Addition. A search group/person has access to a DO (but not the assets)
    def search_groups(pid)
      sg = read_groups(pid) | (get_permission_key(pid, self.class.search_group_field) || [])
      Rails.logger.debug("[CANCAN] search_groups: #{sg.inspect}")
      sg
    end

    # 383 Addition
    def search_users(pid)
      sp = read_users(pid) | (get_permission_key(pid, self.class.search_user_field) || [])
      Rails.logger.debug("[CANCAN] manager_persons: #{sp.inspect}")
      sp
    end

    module ClassMethods
      def read_group_field
        Blacklight::AccessControls.config.permissions.read.group
      end

      def edit_user_field
        Blacklight::AccessControls.config.permissions.edit.individual
      end

      def read_user_field
        Blacklight::AccessControls.config.permissions.read.individual
      end

      def edit_group_field
        Blacklight::AccessControls.config.permissions.edit.group
      end

      # 383 Addition
      def manager_group_field
        Blacklight::AccessControls.config.permissions.manager.group
      end

      # 383 Addition
      def manager_user_field
        Blacklight::AccessControls.config.permissions.manager.individual
      end

      # 383 Addition
      def search_group_field
        Blacklight::AccessControls.config.permissions.discover.group
      end

      # 383 Addition
      def search_user_field
        Blacklight::AccessControls.config.permissions.discover.individual
      end
    end
  end
end
