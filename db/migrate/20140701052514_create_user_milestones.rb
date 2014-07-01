class CreateUserMilestones < ActiveRecord::Migration
  def change
    create_table :user_milestones do |t|
      t.integer :user_id
      t.integer :time_unit_id
      t.integer :milestone_id
      t.string :module
      t.string :submodule

      t.timestamps
    end
  end
end
