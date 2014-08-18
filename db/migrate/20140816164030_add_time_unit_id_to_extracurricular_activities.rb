class AddTimeUnitIdToExtracurricularActivities < ActiveRecord::Migration
  def change
    add_column :user_extracurricular_activities, :time_unit_id, :integer
  end
end
