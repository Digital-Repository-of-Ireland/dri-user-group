class AddProfileImageToUsers < ActiveRecord::Migration
  def change
    add_column :user_group_users, :image_link, :string, default: nil
  end
end