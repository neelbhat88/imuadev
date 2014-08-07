class FixExtracurricularAndServiceModel < ActiveRecord::Migration
  def change
    rename_table :user_extracurricular_activity_details, :user_extracurricular_activity_events
    rename_table :user_service_orgs, :user_service_activities
    rename_table :user_service_hours, :user_service_activity_events
    rename_column :user_service_activity_events, :service_org_id, :user_service_org_id
    remove_column :user_service_activities, :time_unit_id
    remove_column :user_extracurricular_activities, :time_unit_id
    add_column :user_extracurricular_activities, :description, :string
    remove_column :user_extracurricular_activities, :position
    add_column :user_extracurricular_activity_events, :name, :string
    add_column :user_extracurricular_activity_events, :leadership, :string
    add_column :user_service_activities, :description, :string
    add_column :user_service_activity_events, :name, :string
    add_column :user_service_activity_events, :description, :string
    rename_column :user_service_activity_events, :user_service_org_id, :user_service_activity_id
    rename_column :user_extracurricular_activity_events, :extracurricular_activity_id, :user_extracurricular_activity_id
  end
end
