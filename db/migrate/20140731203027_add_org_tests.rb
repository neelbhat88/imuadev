class AddOrgTests < ActiveRecord::Migration
  def change
    create_table :org_tests do |t|
      t.integer :organization_id
      t.string  :title
      t.integer :score_type
      t.string  :description

      t.timestamps
    end
  end
end
