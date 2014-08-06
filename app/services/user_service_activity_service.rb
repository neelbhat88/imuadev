class UserServiceActivityService

  def get_user_service_activities(userId)
    return UserServiceActivity.where(:user_id => userId).order(:id)
  end

  def get_user_service_activity_events(userId, time_unit_id)
    return UserServiceActivityEvent.where(:user_id => userId, :time_unit_id => time_unit_id).order(:id)
  end

  def get_service_events_for_activity(user_service_activity, userId)
    return UserServiceActivityEvent.where(:service_activity_id => user_service_activity[:id], :user_id => userId)
  end

  def save_user_service_activity(user_service_activity)
    new_service_activity = UserServiceActivity.new do | u |
      u.user_id = user_service_activity[:user_id]
      u.name = user_service_activity[:name]
      u.description = user_service_activity[:description]
    end

    if new_service_activity.save
      return new_service_activity
    else
      return nil
    end
  end

  def save_user_service_activity_event(user_service_activity_event)
    new_service_activity_event = UserServiceActivityEvent.new do | u |
      u.user_id = user_service_activity_event[:user_id]
      u.date = user_service_activity_event[:date]
      u.hours = user_service_activity_event[:hours]
      u.user_service_activity_id = user_service_activity_event[:user_service_activity_id]
      u.time_unit_id = user_service_activity_event[:time_unit_id]
    end

    if new_service_activity_event
      return new_service_activity_event
    else
      return nil
    end
  end

  def update_user_service_activity(serviceActivityId, user_service_activity)
    db_class = UserServiceActivity.find(serviceActivityId)
    if db_class.update_attributes(:name => user_service_activity[:name], :description => user_service_activity[:description])
      return db_class
    else
      return nil
    end
  end

  def update_user_service_activity_event(serviceActivityEventId, user_service_activity_event)
    db_class = UserServiceActivityEvent.find(serviceActivityEventId)
    if db_class.update_attributes(:date => user_service_activity_event[:date], :hours => user_service_activity_event[:hours])
      return db_class
    else
      return nil
    end
  end

  def delete_user_service_activity(serviceActivityId)
    if UserServiceActivity.find(serviceActivityId).destroy()
      return true
    else
      return false
    end
  end

  def delete_user_service_activity_event(serviceActivityEventId)
    if UserServiceActivityEvent.find(serviceActivityEventId).destroy()
      return true
    else
      return false
    end
  end

end
