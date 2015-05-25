class AddReaderGroupToUserGroupGroups < ActiveRecord::Migration
  def change
    add_column :user_group_groups, :reader_group, :boolean, :default => false
  end
end
