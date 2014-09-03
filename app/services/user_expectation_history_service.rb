class UserExpectationHistoryService

  def get_expectation_histories(userId, expectationId)
    return UserExpectationHistory.where(:user_id=> userId,
                             :expectation_id => expectationId)
  end

  def create_expectation_history(userExpectation)
    expectation = Expectation.where(:id => userExpectation[:expectation_id]).first

    newExpectationHistory = UserExpectationHistory.new do | e |
      e.expectation_id = expectation.id
      e.user_expectation_id = userExpectation.id
      e.modified_by_id = userExpectation.modified_by_id
      e.user_id = userExpectation.user_id
      e.status = userExpectation.status
      e.title = expectation.title
      e.rank = expectation.rank
    end

    if !newExpectationHistory.valid?
      # TODO
    end

    if newExpectationHistory.save
      return ReturnObject.new(:ok, "Successfully created Expectation History, id: #{newExpectationHistory.id}.", newExpectationHistory)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create expectation history. Errors: #{newExpectationHistory.errors}", nil)
    end
  end

end
