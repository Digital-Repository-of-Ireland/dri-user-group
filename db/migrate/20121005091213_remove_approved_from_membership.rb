class RemoveApprovedFromMembership < ActiveRecord::Migration[4.2]
  def up
    remove_column :memberships, :approved
  end

  def down
    add_column :memberships, :approved, :boolean
  end
end
