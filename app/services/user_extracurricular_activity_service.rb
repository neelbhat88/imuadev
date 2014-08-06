class UserExtracurricularActivityService

  # time_unit_id will be used for now, discuss later
  def get_user_extracurricular_activities(userId)
    return UserExtracurricularActivity.where(:user_id => userId).order(:id)
  end

  def get_user_extracurricular_activity_events(userId, time_unit_id)
    return UserExtracurricularActivityEvent.where(:user_id => userId, :time_unit_id => time_unit_id).order(:id)
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
      return new_extracurricular
    else
      return nil
    end
  end

  def save_user_extracurricular_activity_event(user_extracurricular_activity_event)
    new_activity_event = UserExtracurricularActivityEvent.new do | u |
      u.user_id = user_extracurricular_activity_event[:user_id]
      u.description = user_extracurricular_activity_event[:description]
      u.leadership = user_extracurricular_activity_event[:leadership]
      u.name = user_extracurricular_activity_event[:name]
      u.user_extracurricular_activity_id =
        user_extracurricular_activity_event[:extracurricular_activity_id]
      u.time_unit_id = user_extracurricular_activity_event[:time_unit_id]
    end

    if new_activity_event
      return new_activity_event
    else
      return nil
    end
  end

  def update_user_extracurricular_activity(extracurricularActivityId, user_extracurricular_activity)
    db_class = UserExtracurricularActivity.find(extracurricularActivityId)
    if db_class.update_attributes(:name => user_extracurricular_activity[:name], :description => user_extracurricular_activity[:description])
      return db_class
    else
      return nil
    end
  end

  def update_user_extracurricular_activity_event(extracurricularActivityEventId, user_extracurricular_activity_event)
    db_class = UserExtracurricularActivityEvent.find(extracurricularActivityEventId)
    if db_class.update_attributes(:description => user_extracurricular_activity_event[:description], :leadership => user_extracurricular_activity_event[:leadership], :name => user_extracurricular_activity_event[:name])
      return db_class
    else
      return nil
    end
  end

  def delete_user_extracurricular_activity(extracurricularActivityId)
    if UserExtracurricularActivity.find(extracurricularActivityId).destroy()
      return true
    else
      return false
    end
  end

  def delete_user_extracurricular_activity_event(extracurricularActivityEventId)
    if UserExtracurricularActivityEvent.find(extracurricularActivityEventId).destroy()
      return true
    else
      return false
    end
  end

end
