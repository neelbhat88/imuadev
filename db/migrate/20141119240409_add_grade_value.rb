class AddGradeValue < ActiveRecord::Migration
  def change
    add_column :user_classes, :grade_value, :float
    add_column :user_class_histories, :grade_value, :float
  end
end
