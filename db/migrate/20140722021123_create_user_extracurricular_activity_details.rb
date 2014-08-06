class CreateUserExtracurricularActivityDetails < ActiveRecord::Migration
  def change
    create_table :user_extracurricular_activity_details do |t|
      t.integer :extracurricular_activity_id
      t.string :description
      t.integer :user_id
      t.integer :time_unit_id

      t.timestamps
    end
  end
end
