class AssignmentTypeToContext < ActiveRecord::Migration
  def change
    rename_column :assignments, :type, :context
    rename_column :assignments, :type_id, :context_id
  end
end
