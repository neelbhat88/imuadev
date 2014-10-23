class UpdateStringToTextInDb < ActiveRecord::Migration
  def up
    change_column :user_service_hours, :name, :text
    change_column :user_service_hours, :description, :text
    change_column :assignments, :title, :text
    change_column :assignments, :description, :text
    change_column :user_extracurricular_activities, :name, :text
    change_column :user_extracurricular_activities, :description, :text
  end

  def down
    change_column :user_service_hours, :name, :string
    change_column :user_service_hours, :description, :string
    change_column :assignments, :title, :string
    change_column :assignments, :description, :string
    change_column :user_extracurricular_activities, :name, :string
    change_column :user_extracurricular_activities, :description, :string
  end
end
