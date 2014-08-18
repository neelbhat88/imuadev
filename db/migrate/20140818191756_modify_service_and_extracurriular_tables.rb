class ModifyServiceAndExtracurriularTables < ActiveRecord::Migration
  def change
    rename_table :user_extracurricular_activity_events, :user_extracurricular_activity_details
    rename_table :user_service_activities, :user_service_organizations
    rename_table :user_service_activity_events, :user_service_hours
    remove_column :user_extracurricular_activities, :time_unit_id
    remove_column :user_service_hours, :user_service_activity_id, :user_service_organization_id
  end
end
