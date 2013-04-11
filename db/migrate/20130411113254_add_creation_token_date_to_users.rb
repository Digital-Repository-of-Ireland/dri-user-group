class AddCreationTokenDateToUsers < ActiveRecord::Migration
  def change
    add_column :user_group_users, :token_creation_date, :datetime
  end
end