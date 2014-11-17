class UserExpectationHistoryService

  def initialize(current_user)
    @current_user = current_user
  end

  def get_user_expectation_history(user_expectation_id)
    history = UserExpectationHistory.where(:user_expectation_id => user_expectation_id).order("created_at DESC")

    return history.map{ |h|
        {
          :status => h.status,
          :modified_by_name => h.modified_by_name,
          :comment => h.comment,
          :created_on => h.created_on
        }
      }
  end

  def create_expectation_history(userExpectation)
    expectation = Expectation.find(userExpectation.expectation_id)

    UserExpectationHistory.create(
      :expectation_id => expectation.id,
      :user_expectation_id => userExpectation.id,
      :modified_by_id => userExpectation.modified_by_id,
      :modified_by_name => userExpectation.modified_by_name,
      :user_id => userExpectation.user_id,
      :status => userExpectation.status,
      :title => expectation.title,
      :rank => expectation.rank,
      :comment => userExpectation.comment,
      :created_on => userExpectation.updated_at
    )

  end

end
