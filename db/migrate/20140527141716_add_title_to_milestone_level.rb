class AddTitleToMilestoneLevel < ActiveRecord::Migration
  def change
    add_column :milestone_levels, :title, :string
  end
end
