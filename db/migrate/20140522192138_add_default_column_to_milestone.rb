class AddDefaultColumnToMilestone < ActiveRecord::Migration
  def change
    add_column :milestones, :is_default, :boolean, default: false
  end
end
