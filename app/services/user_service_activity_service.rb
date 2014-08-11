class UserServiceActivityService

  def get_user_service_activities(userId)
    return UserServiceActivity.where(:user_id => userId).order(:id)
  end

  def get_user_service_activity_events(userId, time_unit_id)
    return UserServiceActivityEvent.where(:user_id => userId, :time_unit_id => time_unit_id).order(:id)
  end

  def get_user_service_activity(serviceActivityId)
    return UserServiceActivity.where(:id => serviceActivityId).first
  end

  def get_user_service_activity_event(serviceActivityEventId)
    return UserServiceActivityEvent.where(:id => serviceActivityEventId).first
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
      return ReturnObject.new(:ok, "Successfully created Service Activity, id: #{new_service_activity.id}", new_service_activity)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create Service Activity. Errors: #{new_service_activity.errors.inspect}", nil)
    end
  end

  def save_user_service_activity_event(user_service_activity_event)
    new_service_activity_event = UserServiceActivityEvent.new do | u |
      u.user_id = user_service_activity_event[:user_id]
      u.date = user_service_activity_event[:date]
      u.description = user_service_activity_event[:description]
      u.hours = user_service_activity_event[:hours]
      u.user_service_activity_id = user_service_activity_event[:user_service_activity_id]
      u.time_unit_id = user_service_activity_event[:time_unit_id]
    end

    if new_service_activity_event.save
      return ReturnObject.new(:ok, "Successfully created Service Activity Event, id: #{new_service_activity_event.id}", new_service_activity_event)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create Service Activity Event. Errors: #{new_service_activity_event.errors.inspect}", nil)
    end
  end

  def update_user_service_activity(serviceActivityId, user_service_activity)
    db_class = UserServiceActivity.find(serviceActivityId)
    if db_class.update_attributes(:name => user_service_activity[:name], :description => user_service_activity[:description])
      return ReturnObject.new(:ok, "Successfully updated Service Activity, id: #{db_class.id}", db_class)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update Service Activity. Errors: #{db_class.errors.inspect}", nil)
    end
  end

  def update_user_service_activity_event(serviceActivityEventId, user_service_activity_event)
    db_class = UserServiceActivityEvent.find(serviceActivityEventId)
    if db_class.update_attributes(:description => user_service_activity_event[:description], :date => user_service_activity_event[:date], :hours => user_service_activity_event[:hours])
      return ReturnObject.new(:ok, "Successfully updated Service Activity Event, id: #{db_class.id}", db_class)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update Service Activity Event. Errors: #{db_class.errors.inspect}", nil)
    end
  end

  def delete_user_service_activity(serviceActivityId)
    if UserServiceActivity.find(serviceActivityId).destroy()
      return ReturnObject.new(:ok, "Successfully deleted Service Activity, id: #{serviceActivityId}", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete Service Activity. id: #{serviceActivityId}", nil)
    end
  end

  def delete_user_service_activity_event(serviceActivityEventId)
    if UserServiceActivityEvent.find(serviceActivityEventId).destroy()
      return ReturnObject.new(:ok, "Successfully deleted Service Activity Event, id: #{serviceActivityEventId}", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create Service Activity Event. id: #{serviceActivityEventId}", nil)
    end
  end

end
