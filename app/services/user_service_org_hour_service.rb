class UserServiceOrgHourService

  # time_unit_id will be used for now, discuss later
  def get_user_service_orgs(userId, time_unit_id)
    return UserServiceOrg.where(:user_id => userId, :time_unit_id => time_unit_id).order(:id)
  end

  def get_user_service_hours(userId, time_unit_id)
    return UserServiceHour.where(:user_id => userId, :time_unit_id => time_unit_id).order(:id)
  end

  def get_service_hours_for_org(user_service_org, userId)
    return UserServiceHour.where(:service_org_id => user_service_org[:id], :user_id => userId)
  end

  def save_user_service_org(userId, user_service_org)
    new_service_org = UserServiceOrg.new do | u |
      u.user_id = userId
      u.name = user_service_org[:name]
      u.time_unit_id = user_service_org[:time_unit_id]
    end

    if new_service_org.save
      return new_service_org
    else
      return nil
    end
  end

  def save_user_service_hours(userId, user_service_hour)
    new_service_hour = UserServiceHour.new do | u |
      u.user_id = userId
      u.date = user_service_hour[:date]
      u.hours = user_service_hour[:hours]
      u.service_org_id = user_service_hour[:service_org_id]
      u.time_unit_id = user_service_hour[:time_unit_id]
    end

    if new_service_hour
      return new_service_hour
    else
      return nil
    end
  end

  def update_user_service_org(user_service_org)
    db_class = UserServiceOrg.find(user_service_org[:id])
    if db_class.update_attributes(:name => user_service_org[:name])
      return db_class
    else
      return nil
    end
  end

  def update_user_service_hour(user_service_hour)
    db_class = UserServiceHour.find(user_service_hour[:id])
    if db_class.update_attributes(:date => user_service_hour[:date], :hours => user_service_hour[:hours])
      return db_class
    else
      return nil
    end
  end

  def delete_user_service_org(serviceOrgId)
    if UserServiceOrg.find(serviceOrgId).destroy()
      return true
    else
      return false
    end
  end

  def delete_user_service_hour(serviceHourId)
    if UserServiceHour.find(serviceHourId).destroy()
      return true
    else
      return false
    end
  end

end
