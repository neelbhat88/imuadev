class ExpectationService

  #####################################
  ########### ORGANIZATION ############
  #####################################

  def get_expectations(orgId)
    return Expectation.where(:organization_id => orgId)
  end

  def create_expectation(expectation)
    newExpectation = Expectation.new do | e |
      e.orgId = expectation[:organization_id]
      e.title = expectation[:title]
      e.description = expectation[:description]
      e.rank = expectation[:rank]
    end

    if !newExpectation.valid?
    end

    if newExpectation.save
      return ReturnObject.new(:ok, "Successfully created Expectation, id: #{newExpectation.id}.", newExpectation)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create expectation.", nil)
    end
  end

  def update_expectation(expectation)
    dbExpectation = Expectation.find(expectation[:id])

    # TODO Check title uniqueness within Organization's set of Expectations

    if dbExpectation.update_attributes(:title => expectation[:title],
                                       :description => expectation[:description],
                                       :rank => expectation[:rank])
      return ReturnObject.new(:ok, "Successfully updated Expectation, id: #{dbExpectation.id}.", dbExpectation)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update Expectation, id: #{dbExpectation.id}", nil)
    end
  end

  def delete_expectation(expectationId)
    if Expectation.find(expectationId).destroy()
      return ReturnObject.new(:ok, "Successfully deleted Expectation, id: #{expectationId}.", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete Expectation, id: #{expectationId}.", nil)
    end
  end

  #################################
  ############# USER ##############
  #################################

  def get_user_expectations(userId)
    return UserExpectation.where(:user_id => userId)
  end

  def create_user_expectation(userExpectation)
    newUserExpectation = UserExpectation.new do | e |
      e.user_id = userExpectation[:user_id]
      e.expectation_id = userExpectation[:expectation_id]
      e.status = userExpectation[:status]
    end

    if !newUserExpectation.valid?
    end

    if newUserExpectation.save
      return ReturnObject.new(:ok, "Successfully created UserExpectation, id: #{newUserExpectation.id}.", newUserExpectation)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create UserExpectation.", nil)
    end
  end

  def update_user_expectation(userExpectation)
    dbUserExpectation = UserExpectation.find(userExpectation[:id])

    if dbUserExpectation.update_attributes(:status => userExpectation[:status])
      return ReturnObject.new(:ok, "Successfully updated UserExpectation, id: #{dbUserExpectation.id}.", dbUserExpectation)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update UserExpectation, id: #{dbUserExpectation.id}", nil)
    end
  end

  def delete_user_expectation(userExpectationId)
    if UserExpectation.find(userExpectationId).destroy()
      return ReturnObject.new(:ok, "Successfully deleted UserExpectation, id: #{userExpectationId}.", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete UserExpectation, id: #{userExpectationId}.", nil)
    end
  end

end
