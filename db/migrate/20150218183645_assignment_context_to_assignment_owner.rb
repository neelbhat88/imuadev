class AssignmentContextToAssignmentOwner < ActiveRecord::Migration
  def change
    rename_column :assignments, :context, :assignment_owner_type
    rename_column :assignments, :context_id, :assignment_owner_id

    remove_index "assignments", name: "index_assignments_on_user_id"
    add_index "assignments", ["assignment_owner_type", "assignment_owner_id"], :name => "index_assignments_on_owner_type_and_owner_id"
  end
end
