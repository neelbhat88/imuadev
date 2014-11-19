class UserClassHistoryService

  def get_history_for_class(user_class_id)
    UserClassHistory.where(:user_class_id => user_class_id).order('created_at DESC')
  end

  def log_history(user, user_class)
    UserClassHistory.create(:credit_hours => user_class.credit_hours,
                            :gpa => user_class.gpa,
                            :grade => user_class.grade,
                            :grade_value => user_class.grade_value,
                            :level => user_class.level,
                            :name => user_class.name,
                            :period => user_class.period,
                            :room => user_class.room,
                            :subject => user_class.subject,
                            :time_unit_id => user_class.time_unit_id,
                            :user_class_id => user_class.id,
                            :user_id => user_class.user_id,
                            :modified_by_id => user.id,
                            :modified_by_name => user.full_name)
  end

end
