class CreateTimeUnits < ActiveRecord::Migration
  def change
    create_table :time_units do |t|
      t.string :name
      t.integer :roadmap_id
      t.integer :organization_id

      t.timestamps
    end

    add_index :time_units, :roadmap_id, :name => 'IDX_TimeUnit_RoadmapId'
  end
end
