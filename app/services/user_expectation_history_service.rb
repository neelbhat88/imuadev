class UserExpectationHistoryService

  def get_user_expectation_history(user_expectation_id)
    history = UserExpectationHistory.where(:user_expectation_id => user_expectation_id).order("created_at DESC")

    return history.map{ |h|
        {
          :status => h.status,
          :modified_by_name => h.modified_by_name,
          :comment => h.comment,
          :updated_at => h.updated_at
        }
      }
  end

  def create_expectation_history(userExpectation, current_user)
    expectation = Expectation.find(userExpectation.expectation_id)

    UserExpectationHistory.create(
      :expectation_id => expectation.id,
      :user_expectation_id => userExpectation.id,
      :modified_by_id => current_user.id,
      :modified_by_name => current_user.full_name,
      :user_id => userExpectation.user_id,
      :status => userExpectation.status,
      :title => expectation.title,
      :rank => expectation.rank,
      :comment => userExpectation.comment
    )

  end

end
