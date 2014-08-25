class UpdateALotOfIndices < ActiveRecord::Migration
  def change
    add_index "user_milestones", "user_id"
    add_index "user_expectations", "user_id"

    add_index "expectations", "organization_id"

    add_index "org_tests", "organization_id"
    add_index "user_tests", "user_id"

    remove_index "milestones", :name => "IDX_Milestone_TimeUnitId"
    add_index "milestones", "organization_id"
    add_index "milestones", ["time_unit_id", "submodule", "module", "value"], :name => "index_milestones_on_time_submod_mod_and_val", :unique => true

    add_index "relationships", "user_id"
    add_index "relationships", "assigned_to_id"

    add_index "roadmaps", "organization_id"

    remove_index "time_units", :name => "IDX_TimeUnit_RoadmapId"
    add_index "time_units", "organization_id"

    add_index "user_classes", "user_id"

    add_index "user_extracurricular_activities", "user_id"
    add_index "user_extracurricular_activity_details", "user_id"

    add_index "user_service_organizations", "user_id"
    add_index "user_service_hours", "user_id"

    add_index "parent_guardian_contacts", "user_id"

  end
end
