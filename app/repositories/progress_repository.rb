class ProgressRepository

  def get_user_classes(userId, time_unit_id)
    return UserClass.where(:user_id => userId, :time_unit_id => time_unit_id)
  end

end