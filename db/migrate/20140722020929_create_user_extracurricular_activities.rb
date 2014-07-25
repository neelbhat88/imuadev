class CreateUserExtracurricularActivities < ActiveRecord::Migration
  def change
    create_table :user_extracurricular_activities do |t|
      t.string :name
      t.string :position
      t.integer :user_id
      t.integer :time_unit_id

      t.timestamps
    end
  end
end
