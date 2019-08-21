class RenameUsersTable < ActiveRecord::Migration[4.2]
	def change
		rename_table :users, :user_group_users
	end
end
