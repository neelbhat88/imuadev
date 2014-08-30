class AddIndexesToAssignmentTables < ActiveRecord::Migration
  def change
    add_index "assignments", "user_id"
    add_index "user_assignments", "user_id"
    add_index "user_assignments", "assignment_id"
    add_index "user_assignments", ["assignment_id", "user_id"], :unique => true
  end
end
