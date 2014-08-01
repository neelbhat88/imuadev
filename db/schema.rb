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

ActiveRecord::Schema.define(:version => 20140801271125) do

  create_table "expectations", :force => true do |t|
    t.integer  "organization_id"
    t.string   "title"
    t.string   "description"
    t.integer  "rank"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

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

  add_index "milestones", ["time_unit_id"], :name => "IDX_Milestone_TimeUnitId"

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "relationships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "assigned_to_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "roadmaps", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "organization_id"
  end

  create_table "time_units", :force => true do |t|
    t.string   "name"
    t.integer  "roadmap_id"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "time_units", ["roadmap_id"], :name => "IDX_TimeUnit_RoadmapId"

  create_table "user_classes", :force => true do |t|
    t.string   "name"
    t.string   "grade"
    t.float    "gpa"
    t.integer  "user_id"
    t.integer  "time_unit_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "user_classes", ["user_id", "time_unit_id"], :name => "IDX_UserClass_UserIdTimeUnitId"

  create_table "user_expectations", :force => true do |t|
    t.integer  "expectation_id"
    t.integer  "user_id"
    t.integer  "status"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "user_extracurricular_activities", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "description"
  end

  create_table "user_extracurricular_activity_events", :force => true do |t|
    t.integer  "extracurricular_activity_id"
    t.string   "description"
    t.integer  "user_id"
    t.integer  "time_unit_id"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.string   "name"
    t.string   "leadership"
  end

  create_table "user_milestones", :force => true do |t|
    t.integer  "user_id"
    t.integer  "time_unit_id"
    t.integer  "milestone_id"
    t.string   "module"
    t.string   "submodule"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "user_service_activities", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "description"
  end

  create_table "user_service_activity_events", :force => true do |t|
    t.integer  "user_service_org_id"
    t.decimal  "hours"
    t.date     "date"
    t.integer  "user_id"
    t.integer  "time_unit_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "name"
    t.string   "description"
  end

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
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["organization_id"], :name => "IDX_User_OrganizationId"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
