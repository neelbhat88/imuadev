class AddOrganizationIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :organization_id, :integer

    add_index :users, :organization_id, :name => 'IDX_User_OrganizationId'
  end
end
