class RemoveApprovedFromMembership < ActiveRecord::Migration
  def up
    remove_column :memberships, :approved
  end

  def down
    add_column :memberships, :approved, :boolean
  end
end
