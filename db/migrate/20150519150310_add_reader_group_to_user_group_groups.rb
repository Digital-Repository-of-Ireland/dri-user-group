class AddReaderGroupToUserGroupGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :user_group_groups, :reader_group, :boolean, :default => false
  end
end
