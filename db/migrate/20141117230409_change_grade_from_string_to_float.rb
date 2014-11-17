class ChangeGradeFromStringToFloat < ActiveRecord::Migration
  def up
    change_column :user_classes, :grade, 'double precision USING CAST(grade AS double precision)'
  end

  def down
    change_column :user_classes, :grade, :string
  end
end
