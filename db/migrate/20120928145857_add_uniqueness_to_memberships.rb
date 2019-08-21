class AddUniquenessToMemberships < ActiveRecord::Migration[4.2]
  def change
    add_index :memberships, [:group_id, :user_id], :unique => true
  end
end
