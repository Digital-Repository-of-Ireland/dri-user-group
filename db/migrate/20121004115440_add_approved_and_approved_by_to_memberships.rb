class AddApprovedAndApprovedByToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :approved, :boolean, default: 1
    add_column :memberships, :approved_by, :integer
  end
end
