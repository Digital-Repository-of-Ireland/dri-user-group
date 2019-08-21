class AddProfileImageToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :user_group_users, :image_link, :string, default: nil
  end
end