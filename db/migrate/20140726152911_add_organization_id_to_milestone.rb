class AddOrganizationIdToMilestone < ActiveRecord::Migration
  def change
    add_column :milestones, :organization_id, :integer
  end
end
