class AddPositionToUserExtracurricularActivity < ActiveRecord::Migration
  def change
    add_column :user_extracurricular_activities, :position, :string
  end
end
