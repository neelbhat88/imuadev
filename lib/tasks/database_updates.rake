namespace :db_update do
  ########################################
  ########################################
  #              ALL TASKS
  ########################################
  ########################################
  desc "All db_updates"
  task :all => [:create_app_version,
                :organization_id_to_assignments,
                :reset_default_expectation_descriptions]

  ########################################
  ########################################
  #          POST DEPLOY TASKS
  ########################################
  ########################################
  desc "Post deploy updates"
  task :post_deploy => :environment do
    puts 'Updating AppVersion...'
    num = AppVersion.first.version_number
    new_version = num + 1
    success = AppVersion.first.update_attributes(:version_number => new_version)
    if success
      puts "Updated AppVersion to: #{new_version}"

      puts "Adding new_relic deploy event"
      sh "curl -H 'x-api-key:#{ENV['NEW_RELIC_API_KEY']}' -d 'deployment[app_name]=#{ENV['NEW_RELIC_APP_NAME']}' -d 'deployment[revision]=v#{new_version}' https://api.newrelic.com/deployments.xml"
    else
      puts 'ERROR: Failed to updated AppVersion.'
    end
  end

  ########################################
  ########################################
  #          INDIVIDUAL TASKS
  ########################################
  ########################################
  desc "Sets all credit_hours = 1 and level = 'Regular' for all User Classes where those values
        are nil"
  task :update_all_user_classes => :environment do
    UserClass.where(:credit_hours => nil).update_all(:credit_hours => 1)
    UserClass.where(:level => nil).update_all(:level => "Regular")
  end

  desc "consolidate_service_organizations"
  task :update_all_organizations_and_hours => :environment do
    all_users = User.where(:role => 50)
    all_users.each do | u |
      orgs = UserServiceOrganization.where(:user_id => u.id).order(:id)
      orgNames = {}
      duplicateOrgs = {}
      orgs.each do | o |
        if orgNames.has_value? o.name
          duplicateOrgs[o.id] = o.name
        else
          orgNames[o.id] = o.name
        end
      end

      puts 'Duplicate Organizations:'
      puts duplicateOrgs.to_yaml

      duplicateOrgs.each do | orgId, orgName |
        dupOrgs = UserServiceOrganization.where(:user_id => u.id, :name => orgName)
        if dupOrgs.any?
          dupOrgs.each do |dupOrg|
            hours = UserServiceHour.where(:user_service_organization_id => dupOrg.id)
            hours.update_all(:user_service_organization_id => orgId)
            if dupOrg.id != orgId
              puts 'Deleting ' + dupOrg.name + ' id: ' + dupOrg.id.to_s
              UserServiceOrganization.destroy(dupOrg.id)
            end
          end
        end
      end

    end
  end

  desc "consolidate_extracuricular_activities"
  task :update_all_extracurricular_activities_and_details => :environment do
    all_users = User.where(:role => 50)
    all_users.each do | u |
      activities = UserExtracurricularActivity.where(:user_id => u.id).order(:id)
      activityNames = {}
      duplicateActivities = {}
      activities.each do | a |
        if activityNames.has_value? a.name
          duplicateActivities[a.id] = a.name
        else
          activityNames[a.id] = a.name
        end
      end

      puts 'Duplicate Activities:'
      puts duplicateActivities.to_yaml

      duplicateActivities.each do | activityId, activityName |
        dupActivities = UserExtracurricularActivity.where(:user_id => u.id, :name => activityName)
        if dupActivities.any?
          dupActivities.each do |dupActivity|
            details = UserExtracurricularActivityDetail.where(:user_extracurricular_activity_id => dupActivity.id)
            details.update_all(:user_extracurricular_activity_id => activityId)
            if dupActivity.id != activityId
              puts 'Deleting ' + dupActivity.name + ' id: ' + dupActivity.id.to_s
              UserExtracurricularActivity.destroy(dupActivity.id)
            end
          end
        end
      end

    end
  end

  desc "create initial user gpas"
  task :create_initial_user_gpa => :environment do
    users = User.where(:role => 50)
    users.each do | u |
      time_unit_ids = TimeUnit.where(:organization_id => u.organization_id)
      time_unit_ids.each do | t |
        saved_gpa = UserGpaService.new.calculate_gpa(u.id, t.id)
        if !saved_gpa.nil?
         puts 'Created: ' + saved_gpa.to_yaml
        end
      end
    end
  end

  desc "Create an AppVersion row to store current AppVersion"
  task :create_app_version => :environment do
    if AppVersion.all.length == 0
      AppVersion.create(:version_number => 0)
      puts "AppVersion row created"
    else
      puts "AppVersion row already exists"
    end
  end

  desc "Remove first user expectation history item for new saving process"
  task :remove_first_user_expectation_history => :environment do
    all_users = User.where(:role => 50)
    all_users.each do |u|
      user_expectations = UserExpectation.where(:user_id => u.id)
      if user_expectations.any?
        user_expectations.each do |e|
          histories = UserExpectationHistory.where(:user_expectation_id => e.id).order("created_at DESC")
          if histories.any?
            removed_row = histories.shift
            if removed_row.destroy()
              puts "Removed first history item for user_expectation_id = " + removed_row.user_expectation_id.to_yaml
            end
          end
        end
      end
    end
  end

  desc "Apply organization_id to Assignments"
  task :organization_id_to_assignments => :environment do
    assignments = Assignment.where(organization_id: nil)
    if assignments.any?
      assignments.each do |a|
        orgId = a.user.organization_id
        a.update_attributes(organization_id: orgId)
        puts "Applied orgId: " + orgId.to_s + " to assignment " + a.id.to_s
      end
    else
      puts "All Assignments have non-nil organization_id"
    end
  end

  desc "Reset default Expectation description field"
  task :reset_default_expectation_descriptions => :environment do
    expectations = Expectation.where(description: "temp description")
    if expectations.any?
      expectations.each do |e|
        e.update_attributes(description: "")
        puts "Changed description from 'temp description' to '', for expectation " + e.id.to_s
      end
    else
      puts "No Expectations have description field of: 'temp description'"
    end
  end

  desc "Convert grades from string to number"
  task :convert_grades_from_string_to_float => :environment do
    all_students = User.where(:role => 50)
    all_students.each do | s |
      student_classes = UserClass.where(:user_id => s.id)
      student_classes.each do | c |
        case c.grade
          when 'A'
            new_grade = 98.0
          when 'A-'
            new_grade = 92.0
          when 'B+'
            new_grade = 89.0
          when 'B'
            new_grade = 85.0
          when 'B-'
            new_grade = 82.0
          when 'C+'
            new_grade = 79.0
          when 'C'
            new_grade = 75.0
          when 'C-'
            new_grade = 72.0
          when 'D+'
            new_grade = 69.0
          when 'D'
            new_grade = 65.0
          when 'D-'
            new_grade = 62.0
          when 'F'
            new_grade = 50.0
        end

        c.update_attributes(:grade => new_grade)
        puts "Updated " + c.name + "grade to " + new_grade.to_s + " for " + s.first_name + " " + s.last_name

      end
    end
  end

end
