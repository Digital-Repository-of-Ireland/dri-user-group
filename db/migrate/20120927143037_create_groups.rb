class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
    add_index :groups, :name, :unique => true
  end
end
