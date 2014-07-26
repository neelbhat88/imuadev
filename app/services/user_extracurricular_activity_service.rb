class UserExtracurricularActivityService

  # time_unit_id will be used for now, discuss later
  def get_user_extracurricular_activity(userId, time_unit_id)
    return UserExtracurricularActivity.where(:user_id => userId, :time_unit_id => time_unit_id).order(:id)
  end

  def get_user_activity_detail(userId, time_unit_id)
    return UserExtracurricularActivityDetail.where(:user_id => userId, :time_unit_id => time_unit_id).order(:id)
  end

  def get_details_for_activity(user_extracurricular_activity, userId)
    return UserExtracurricularActivityDetail.where(:extracurricular_activity_id => user_extracurricular_activity[:id], :user_id => userId)
  end

  def save_user_extracurricular_activity(userId, user_extracurricular_activity)
    new_extracurricular = UserExtracurricularActivity.new do | u |
      u.user_id = userId
      u.name = user_extracurricular_activity[:name]
      u.position = user_extracurricular_activity[:position]
      u.time_unit_id = user_extracurricular_activity[:time_unit_id]
    end

    if new_extracurricular.save
      return new_extracurricular
    else
      return nil
    end
  end

  def save_user_activity_detail(userId, user_extracurricular_activity_detail)
    new_activity_detail = UserExtracurricularActivityDetail.new do | u |
      u.user_id = userId
      u.description = user_extracurricular_activity_detail[:description]
      u.extracurricular_activity_id =
        user_extracurricular_activity_detail[:extracurricular_activity_id]
      u.time_unit_id = user_extracurricular_activity_detail[:time_unit_id]
    end

    if new_activity_detail
      return new_activity_detail
    else
      return nil
    end
  end

  def update_user_extracurricular_activity(user_extracurricular_activity)
    db_class = UserExtracurricularActivity.find(user_extracurricular_activity[:id])
    if db_class.update_attributes(:name => user_service_org[:name], :position => user_extracurricular_activity[:position])
      return db_class
    else
      return nil
    end
  end

  def update_user_activity_detail(user_extracurricular_activity_detail)
    db_class = UserExtracurricularActivityDetail.find(user_extracurricular_activity_detail[:id])
    if db_class.update_attributes(:description => user_extracurricular_activity_detail[:description])
      return db_class
    else
      return nil
    end
  end

  def delete_user_extracurricular_activity(extracurricularActivityId)
    if UserServiceOrg.find(extracurricularActivityId).destroy()
      return true
    else
      return false
    end
  end

  def delete_user_activity_detail(extracurricularActivityDetailId)
    if UserServiceHour.find(extracurricularActivityDetailId).destroy()
      return true
    else
      return false
    end
  end

end
