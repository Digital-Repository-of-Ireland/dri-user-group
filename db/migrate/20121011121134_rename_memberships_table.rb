class RenameMembershipsTable < ActiveRecord::Migration
    def change
        rename_table :memberships, :user_group_memberships
    end
end
