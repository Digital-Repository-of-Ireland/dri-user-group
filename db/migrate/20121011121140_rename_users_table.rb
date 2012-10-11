class RenameUsersTable < ActiveRecord::Migration
	def change
		rename_table :users, :user_group_users
	end
end
