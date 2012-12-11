module UserGroup
    module GroupsHelper
        #does not really seem to be a helper
        def pending_users_count(group)
            group.pending_memberships.count
        end
    end
end
