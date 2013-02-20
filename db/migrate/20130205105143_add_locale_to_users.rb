class AddLocaleToUsers < ActiveRecord::Migration
  def change
    add_column :user_group_users, :locale, :string
  end
end
