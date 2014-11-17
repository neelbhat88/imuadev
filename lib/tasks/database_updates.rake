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

  desc "Create UserExpectations for all Users"
  task :create_user_expectations => :environment do
    User.where(:role => Constants.UserRole[:STUDENT]).each do |u|
      UserExpectationService.new(User.SystemUser).create_user_expectations(u.id)
    end
  end

  desc "Add UserExpectationHistory record"
  # Doing this because at the time of this writing the UserExpectationHistory
  # was always 1 entry behind the current UserEpectation - meaning to build up
  # a full history, including current state, you have to get the history AND
  # get the current UserExpectation. See #615 on github for more explanation
  task :add_user_expectation_history_record => :environment do
    recordsCreated = 0
    UserExpectation.all.each do |ue|
      puts "Adding History Record for UserExpectation id: #{ue.id}"
      existingHistory = UserExpectationHistory.where(
                          :expectation_id => ue.expectation_id,
                          :user_expectation_id => ue.id,
                          :status => ue.status,
                          :comment => ue.comment,
                          :created_on => ue.updated_at
                          )

      puts "Existing history length #{existingHistory.length}"

      if existingHistory.length == 0
        puts "UserExpectation last updated_at: #{ue.updated_at}"

        history = UserExpectationHistoryService.new(User.SystemUser).create_expectation_history(ue)

        if history.valid?
          recordsCreated += 1
          puts "History record created. Setting created_on: #{history.created_on}"
        else
          puts "Failed to create history record for UserExpectation id: #{ue.id}. Errors: #{history.errors.inspect}"
        end
      else
        puts "Latest history record already exists for UserExpectation id: #{ue.id}"
      end
    end

    puts "Creating history records finished. Created #{recordsCreated} records"
  end

  desc "Update UserExpectationHistory Dates to be TO instead of FROM"
  # See #615 on github for more info
  task :update_user_expectation_history_dates => :environment do
    # For all UserExpectations
      # Get all History ordered by created_at DESC
      # 1 - Remove the latest history since it was just added by the rake task above and so is correct
      # 2 - Set created_on date of the LAST one to created_at date of the expectation
      #   and set modified_by_id to SystemUser
      # 3 - Loop through rest and set created_on date of current to created_at of next
    UserExpectation.where(:id => 74).each do |ue|
      expectation = Expectation.find(ue.expectation_id)

      all_history = UserExpectationHistory.where(:user_expectation_id => ue.id).order("created_at DESC")
      puts "History length for User Expectation id #{ue.id}: #{all_history.length}"

      # 1
      all_history.shift

      # 2
      if all_history.length != 0
        all_history.last.update_attributes(:created_on => expectation.created_at, :modified_by_id => -1, :modified_by_name => "System")
      end

      # 3
      all_history.each_with_index do |elem, i|
        next_elem = all_history[i+1]

        if !next_elem.nil?
          elem.update_attributes(:created_on => next_elem.created_at)
        end
      end
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

end
