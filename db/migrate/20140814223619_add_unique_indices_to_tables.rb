class AddUniqueIndicesToTables < ActiveRecord::Migration
  def change
    add_index "expectations", ["organization_id", "title"], :unique => true
    add_index "user_expectations", ["expectation_id", "user_id"], :unique => true

    add_index "org_tests", ["organization_id", "title"], :unique => true

    add_index "relationships", ["user_id", "assigned_to_id"], :unique => true
  end
end
