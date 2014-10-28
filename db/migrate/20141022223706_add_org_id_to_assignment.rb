class AddOrgIdToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :organization_id, :integer
  end
end
