class AssignmentType < ActiveRecord::Migration
  def change
    add_column :assignments, :type, :string
    rename_column :assignments, :user_id, :type_id
  end
end
