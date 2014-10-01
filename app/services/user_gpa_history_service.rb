class UserGpaHistoryService

  def create_gpa_history(user_gpa)

    UserGpaHistory.create(
      :user_gpa_id => user_gpa.id,
      :user_id => user_gpa.user_id,
      :core_unweighted => user_gpa.core_unweighted,
      :core_weighted => user_gpa.core_weighted,
      :regular_unweighted => user_gpa.regular_unweighted,
      :regular_weighted => user_gpa.regular_weighted,
      :time_unit_id => user_gpa.time_unit_id
    )

  end

  def get_user_gpa_history(userId, time_unit_id)
    return UserGpaHistory.where(:user_id => userId, :time_unit_id => time_unit_id)
  end

end
