# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140827191458) do

  create_table "expectations", :force => true do |t|
    t.integer  "organization_id"
    t.string   "title"
    t.string   "description"
    t.integer  "rank"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "expectations", ["organization_id", "title"], :name => "index_expectations_on_organization_id_and_title", :unique => true
  add_index "expectations", ["organization_id"], :name => "index_expectations_on_organization_id"

  create_table "milestone_levels", :force => true do |t|
    t.integer  "milestone_id"
    t.string   "value"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "title"
  end

  add_index "milestone_levels", ["milestone_id"], :name => "IDX_MilestoneLevel_MilestoneId"

  create_table "milestones", :force => true do |t|
    t.string   "module"
    t.string   "submodule"
    t.integer  "importance"
    t.integer  "time_unit_id"
    t.integer  "points"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "is_default",      :default => false
    t.string   "value"
    t.string   "icon"
    t.integer  "organization_id"
  end

  add_index "milestones", ["organization_id"], :name => "index_milestones_on_organization_id"
  add_index "milestones", ["time_unit_id", "submodule", "module", "value"], :name => "index_milestones_on_time_submod_mod_and_val", :unique => true

  create_table "org_tests", :force => true do |t|
    t.integer  "organization_id"
    t.string   "title"
    t.string   "score_type"
    t.string   "description"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "org_tests", ["organization_id", "title"], :name => "index_org_tests_on_organization_id_and_title", :unique => true
  add_index "org_tests", ["organization_id"], :name => "index_org_tests_on_organization_id"

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "parent_guardian_contacts", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "relationship"
    t.string   "email"
    t.string   "phone"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "parent_guardian_contacts", ["user_id"], :name => "index_parent_guardian_contacts_on_user_id"

  create_table "relationships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "assigned_to_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "relationships", ["assigned_to_id"], :name => "index_relationships_on_assigned_to_id"
  add_index "relationships", ["user_id", "assigned_to_id"], :name => "index_relationships_on_user_id_and_assigned_to_id", :unique => true
  add_index "relationships", ["user_id"], :name => "index_relationships_on_user_id"

  create_table "roadmaps", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "organization_id"
  end

  add_index "roadmaps", ["organization_id"], :name => "index_roadmaps_on_organization_id"

  create_table "time_units", :force => true do |t|
    t.string   "name"
    t.integer  "roadmap_id"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "time_units", ["organization_id"], :name => "index_time_units_on_organization_id"

  create_table "user_classes", :force => true do |t|
    t.string   "name"
    t.string   "grade"
    t.float    "gpa"
    t.integer  "user_id"
    t.integer  "time_unit_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "period"
    t.string   "room"
    t.float    "credit_hours"
    t.string   "level"
    t.string   "subject"
  end

  add_index "user_classes", ["user_id", "time_unit_id"], :name => "IDX_UserClass_UserIdTimeUnitId"
  add_index "user_classes", ["user_id"], :name => "index_user_classes_on_user_id"

  create_table "user_expectations", :force => true do |t|
    t.integer  "expectation_id"
    t.integer  "user_id"
    t.integer  "status"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "user_expectations", ["expectation_id", "user_id"], :name => "index_user_expectations_on_expectation_id_and_user_id", :unique => true
  add_index "user_expectations", ["user_id"], :name => "index_user_expectations_on_user_id"

  create_table "user_extracurricular_activities", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "description"
  end

  add_index "user_extracurricular_activities", ["user_id"], :name => "index_user_extracurricular_activities_on_user_id"

  create_table "user_extracurricular_activity_details", :force => true do |t|
    t.integer  "user_extracurricular_activity_id"
    t.string   "description"
    t.integer  "user_id"
    t.integer  "time_unit_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "name"
    t.string   "leadership"
  end

  add_index "user_extracurricular_activity_details", ["user_id"], :name => "index_user_extracurricular_activity_details_on_user_id"

  create_table "user_milestones", :force => true do |t|
    t.integer  "user_id"
    t.integer  "time_unit_id"
    t.integer  "milestone_id"
    t.string   "module"
    t.string   "submodule"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "user_milestones", ["user_id", "milestone_id"], :name => "index_user_milestones_on_user_id_and_milestone_id", :unique => true
  add_index "user_milestones", ["user_id"], :name => "index_user_milestones_on_user_id"

  create_table "user_service_hours", :force => true do |t|
    t.integer  "user_service_organization_id"
    t.decimal  "hours"
    t.datetime "date"
    t.integer  "user_id"
    t.integer  "time_unit_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "name"
    t.string   "description"
  end

  add_index "user_service_hours", ["user_id"], :name => "index_user_service_hours_on_user_id"

  create_table "user_service_organizations", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "description"
  end

  add_index "user_service_organizations", ["user_id"], :name => "index_user_service_organizations_on_user_id"

  create_table "user_tests", :force => true do |t|
    t.integer  "org_test_id"
    t.integer  "user_id"
    t.integer  "time_unit_id"
    t.datetime "date"
    t.string   "score"
    t.string   "description"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "user_tests", ["user_id"], :name => "index_user_tests_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.integer  "role"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "organization_id"
    t.integer  "time_unit_id"
    t.integer  "class_of"
    t.string   "title"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["organization_id"], :name => "IDX_User_OrganizationId"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
