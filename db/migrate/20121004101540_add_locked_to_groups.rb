class AddLockedToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :is_locked, :boolean, default: 0
  end
end
