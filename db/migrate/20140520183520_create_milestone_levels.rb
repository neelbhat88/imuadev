class CreateMilestoneLevels < ActiveRecord::Migration
  def change
    create_table :milestone_levels do |t|
      t.integer :milestone_id
      t.string :value

      t.timestamps
    end

    add_index :milestone_levels, :milestone_id, :name => 'IDX_MilestoneLevel_MilestoneId'
  end
end
