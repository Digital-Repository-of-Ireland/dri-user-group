class AddLocaleToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :user_group_users, :locale, :string
  end
end
