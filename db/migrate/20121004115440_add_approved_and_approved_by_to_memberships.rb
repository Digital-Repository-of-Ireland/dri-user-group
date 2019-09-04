class AddApprovedAndApprovedByToMemberships < ActiveRecord::Migration[4.2]
  def change
    add_column :memberships, :approved, :boolean, default: 1
    add_column :memberships, :approved_by, :integer
  end
end
