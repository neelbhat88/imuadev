class CreateUserExtracurricularActivities < ActiveRecord::Migration
  def change
    create_table :user_extracurricular_activities do |t|
      t.string :name
      t.integer :user_id

      t.timestamps
    end
  end
end
