class AddLockedToGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :is_locked, :boolean, default: 0
  end
end
