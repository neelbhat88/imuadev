class AddDueDateToMilestone < ActiveRecord::Migration
  def change
    add_column :milestones, :due_datetime, :datetime
  end
end
