class AddUniqueIndexToUserMilestone < ActiveRecord::Migration
  def change
    add_index "user_milestones", ["user_id", "milestone_id"], :unique => true
  end
end
