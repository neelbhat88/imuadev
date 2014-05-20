class CreateRoadmaps < ActiveRecord::Migration
  def change
    create_table :roadmaps do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
