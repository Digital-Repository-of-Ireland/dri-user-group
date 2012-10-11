class RenameGroupsTable < ActiveRecord::Migration
    def change
        rename_table :groups, :user_group_groups
    end
end
