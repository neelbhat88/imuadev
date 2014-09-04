class UserExpectationHistoryService

  def get_expectation_histories(userId, expectationId)
    return UserExpectationHistory.where(:user_id=> userId,
                             :expectation_id => expectationId)
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
      :rank => expectation.rank
    )

  end

end
