class RemoveShibColumnsFromUsers < ActiveRecord::Migration
  def up
    remove_column :user_group_users, :provider
    remove_column :user_group_users, :uid
  end

  def down
    add_column :user_group_users, :provider, :string
    add_column :user_group_users, :uid, :string
  end
end
