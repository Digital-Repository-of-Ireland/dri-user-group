class AddProfileViewLevelToUser < ActiveRecord::Migration
  def change
    add_column :user_group_users, :view_level, :integer, :default => 0
  end
end
