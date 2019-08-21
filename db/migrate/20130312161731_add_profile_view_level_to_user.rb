class AddProfileViewLevelToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :user_group_users, :view_level, :integer, :default => 0
  end
end
