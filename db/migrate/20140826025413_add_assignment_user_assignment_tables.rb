class AddAssignmentUserAssignmentTables < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.integer  :user_id
      t.string   :title
      t.string   :description
      t.datetime :due_datetime

      t.timestamps
    end

    create_table :user_assignments do |t|
      t.integer  :assignment_id
      t.integer  :user_id
      t.integer  :status

      t.timestamps
    end
    
  end
end
