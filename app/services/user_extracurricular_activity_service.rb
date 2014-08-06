class UserExtracurricularActivityService

  # time_unit_id will be used for now, discuss later
  def get_user_extracurricular_activities(userId)
    return UserExtracurricularActivity.where(:user_id => userId).order(:id)
  end

  def get_user_extracurricular_activity_events(userId, time_unit_id)
    return UserExtracurricularActivityEvent.where(:user_id => userId, :time_unit_id => time_unit_id).order(:id)
  end

  def get_user_extracurricular_activity(extracurricularActivityId)
    return UserExtracurricularActivity.where(:id => extracurricularActivityId).first
  end

  def get_user_extracurricular_activity_event(extracurricularActivityEventId)
    return UserExtracurricularActivityEvent.where(:id => extracurricularActivityEventId).first
  end

  def get_events_for_activity(user_extracurricular_activity, userId)
    return UserExtracurricularActivityEvent.where(:extracurricular_activity_id => user_extracurricular_activity[:id], :user_id => userId)
  end

  def save_user_extracurricular_activity(user_extracurricular_activity)
    new_extracurricular = UserExtracurricularActivity.new do | u |
      u.user_id = user_extracurricular_activity[:user_id]
      u.name = user_extracurricular_activity[:name]
      u.description = user_extracurricular_activity[:description]
    end

    if new_extracurricular.save
      return ReturnObject.new(:ok, "Successfully created Extracurricular Activity, id: #{new_extracurricular.id}", new_extracurricular)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create Extracurricular Activity. Errors: #{new_extracurricular.errors}", nil)
    end
  end

  def save_user_extracurricular_activity_event(user_extracurricular_activity_event)
    new_activity_event = UserExtracurricularActivityEvent.new do | u |
      u.user_id = user_extracurricular_activity_event[:user_id]
      u.user_extracurricular_activity_id =
        user_extracurricular_activity_event[:user_extracurricular_activity_id]
      u.description = user_extracurricular_activity_event[:description]
      u.leadership = user_extracurricular_activity_event[:leadership]
      u.name = user_extracurricular_activity_event[:name]
      u.time_unit_id = user_extracurricular_activity_event[:time_unit_id]
    end

    if new_activity_event.save
      return ReturnObject.new(:ok, "Successfully created Extracurricular Activity Event, id: #{new_activity_event.id}", new_activity_event)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create Extracurricular Activity Event. Errors: #{new_activity_event.errors}", nil)
    end
  end

  def update_user_extracurricular_activity(extracurricularActivityId, user_extracurricular_activity)
    db_class = UserExtracurricularActivity.find(extracurricularActivityId)

    if db_class.update_attributes(:name => user_extracurricular_activity[:name], :description => user_extracurricular_activity[:description])
      return ReturnObject.new(:ok, "Successfully updated Extracurricular Activity, id: #{db_class.id}", db_class)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update Extracurricular Activity. Errors: #{db_class.errors}", nil)
    end
  end

  def update_user_extracurricular_activity_event(extracurricularActivityEventId, user_extracurricular_activity_event)
    db_class = UserExtracurricularActivityEvent.find(extracurricularActivityEventId)
    if db_class.update_attributes(:description => user_extracurricular_activity_event[:description], :leadership => user_extracurricular_activity_event[:leadership], :name => user_extracurricular_activity_event[:name])
      return ReturnObject.new(:ok, "Successfully updated Extracurricular Activity Event, id: #{db_class.id}", db_class)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update Extracurricular Activity Event. Errors: #{db_class.errors}", nil)
    end
  end

  def delete_user_extracurricular_activity(extracurricularActivityId)
    if UserExtracurricularActivity.find(extracurricularActivityId).destroy()
      return ReturnObject.new(:ok, "Successfully deleted Extracurricular Activity, id: #{extracurricularActivityId}", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete Extracurricular Activity. id: #{extracurricularActivityId}", nil)
    end
  end

  def delete_user_extracurricular_activity_event(extracurricularActivityEventId)
    if UserExtracurricularActivityEvent.find(extracurricularActivityEventId).destroy()
      return ReturnObject.new(:ok, "Successfully deleted Extracurricular Activity Event, id: #{extracurricularActivityEventId}", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete Extracurricular Activity Event. id: #{extracurricularActivityEventId}", nil)
    end
  end

end
