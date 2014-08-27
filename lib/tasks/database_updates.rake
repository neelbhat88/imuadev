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

    puts duplicateOrgs.to_yaml
    puts orgNames.to_yaml

    duplicateOrgs.each do | orgId, orgName |
      dupOrgs = UserServiceOrganization.where(:user_id => u.id, :name => orgName)
      dupOrgs.each do |dupOrg|
        puts dupOrg.to_yaml
        hours = UserServiceHour.where(:user_service_organization_id => dupOrg.id)
        hours.update_all(:user_service_organization_id => orgId)
        if dupOrg.id != orgId
          UserServiceOrganization.destroy(dupOrg.id)
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

    puts duplicateActivities.to_yaml

    duplicateActivities.each do | activityId, activityName |
      dupActivities = UserExtracurricularActivity.where(:user_id => u.id, :name => activityName)
      dupActivities.each do |dupActivity|
        details = UserExtracurricularActivityDetail.where(:user_extracurricular_activity_id => dupActivity.id)
        details.update_all(:user_extracurricular_activity_id => activityId)
        if dupActivity.id != activityId
          UserExtracurricularActivity.destroy(dupActivity.id)
        end
      end
    end

  end
end
