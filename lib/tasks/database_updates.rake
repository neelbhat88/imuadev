namespace :db_update do
  desc "All db_updates"
  task :all => [:create_app_version]

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

end
