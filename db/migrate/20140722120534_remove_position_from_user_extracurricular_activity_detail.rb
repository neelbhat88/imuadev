class RemovePositionFromUserExtracurricularActivityDetail < ActiveRecord::Migration
  def up
    remove_column :user_extracurricular_activity_details, :position
  end

  def down
    add_column :user_extracurricular_activity_details, :position, :string
  end
end
