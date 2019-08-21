class RenameMembershipsTable < ActiveRecord::Migration[4.2]
    def change
        rename_table :memberships, :user_group_memberships
    end
end
