class UserExtracurricularActivityService

  # time_unit_id will be used for now, discuss later
  def get_user_extracurricular_activities(userId)
    return UserExtracurricularActivity.where(:user_id => userId).order(:id)
  end

  def get_user_extracurricular_activity_details(userId, time_unit_id)
    return UserExtracurricularActivityDetail.where(:user_id => userId, :time_unit_id => time_unit_id).order(:id)
  end

  def get_user_extracurricular_activity(extracurricularActivityId)
    return UserExtracurricularActivity.where(:id => extracurricularActivityId).first
  end

  def get_user_extracurricular_activity_detail(extracurricularActivityDetailId)
    return UserExtracurricularActivityDetail.where(:id => extracurricularActivityDetailId).first
  end

  def get_details_for_activity(user_extracurricular_activity, userId)
    return UserExtracurricularActivityDetail.where(:extracurricular_activity_id => user_extracurricular_activity[:id], :user_id => userId)
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
      return ReturnObject.new(:internal_server_error, "Failed to create Extracurricular Activity. Errors: #{new_extracurricular.errors.inspect}", nil)
    end
  end

  def save_user_extracurricular_activity_detail(user_extracurricular_activity_detail)
    new_activity_detail = UserExtracurricularActivityDetail.new do | u |
      u.user_id = user_extracurricular_activity_detail[:user_id]
      u.user_extracurricular_activity_id =
        user_extracurricular_activity_detail[:user_extracurricular_activity_id]
      u.description = user_extracurricular_activity_detail[:description]
      u.leadership = user_extracurricular_activity_detail[:leadership]
      u.name = user_extracurricular_activity_detail[:name]
      u.time_unit_id = user_extracurricular_activity_detail[:time_unit_id]
    end

    if new_activity_detail.save
      return ReturnObject.new(:ok, "Successfully created Extracurricular Activity Detail, id: #{new_activity_detail.id}", new_activity_detail)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create Extracurricular Activity Detail. Errors: #{new_activity_detail.errors.inspect}", nil)
    end
  end

  def update_user_extracurricular_activity(extracurricularActivityId, user_extracurricular_activity)
    db_class = UserExtracurricularActivity.find(extracurricularActivityId)

    if db_class.update_attributes(:name => user_extracurricular_activity[:name], :description => user_extracurricular_activity[:description])
      return ReturnObject.new(:ok, "Successfully updated Extracurricular Activity, id: #{db_class.id}", db_class)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update Extracurricular Activity. Errors: #{db_class.errors.inspect}", nil)
    end
  end

  def update_user_extracurricular_activity_detail(extracurricularActivityDetailId, user_extracurricular_activity_detail)
    db_class = UserExtracurricularActivityDetail.find(extracurricularActivityDetailId)
    if db_class.update_attributes(:description => user_extracurricular_activity_detail[:description], :leadership => user_extracurricular_activity_detail[:leadership], :name => user_extracurricular_activity_detail[:name])
      return ReturnObject.new(:ok, "Successfully updated Extracurricular Activity Detail, id: #{db_class.id}", db_class)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update Extracurricular Activity Detail. Errors: #{db_class.errors.inspect}", nil)
    end
  end

  def delete_user_extracurricular_activity(extracurricularActivityId)
    if UserExtracurricularActivity.find(extracurricularActivityId).destroy()
      return ReturnObject.new(:ok, "Successfully deleted Extracurricular Activity, id: #{extracurricularActivityId}", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete Extracurricular Activity. id: #{extracurricularActivityId}", nil)
    end
  end

  def delete_user_extracurricular_activity_detail(extracurricularActivityDetailId)
    if UserExtracurricularActivityDetail.find(extracurricularActivityDetailId).destroy()
      return ReturnObject.new(:ok, "Successfully deleted Extracurricular Activity Detail, id: #{extracurricularActivityDetailId}", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete Extracurricular Activity Detail. id: #{extracurricularActivityDetailId}", nil)
    end
  end

end
