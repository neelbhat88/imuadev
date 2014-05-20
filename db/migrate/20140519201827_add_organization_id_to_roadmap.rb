class AddOrganizationIdToRoadmap < ActiveRecord::Migration
  def change
    add_column :roadmaps, :organization_id, :integer
  end
end
