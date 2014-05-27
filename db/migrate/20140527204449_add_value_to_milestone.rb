class AddValueToMilestone < ActiveRecord::Migration
  def change
    add_column :milestones, :value, :string
  end
end
