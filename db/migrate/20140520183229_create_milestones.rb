class CreateMilestones < ActiveRecord::Migration
  def change
    create_table :milestones do |t|
      t.string :module
      t.string :submodule
      t.integer :importance
      t.integer :time_unit_id
      t.integer :points
      t.string :title
      t.text :description

      t.timestamps
    end

    add_index :milestones, :time_unit_id, :name => 'IDX_Milestone_TimeUnitId'

  end
end
