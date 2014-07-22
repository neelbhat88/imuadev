class ExpectationService

  #####################################
  ########### ORGANIZATION ############
  #####################################

  def get_expectation(orgId, expectationId)
    return Expectation.where(:organization_id => orgId,
                             :id => expectationId).first
  end

  def get_expectations(orgId)
    return Expectation.where(:organization_id => orgId)
  end

  def create_expectation(expectation)
    newExpectation = Expectation.new do | e |
      e.organization_id = expectation[:organization_id]
      e.title = expectation[:title]
      e.description = expectation[:description]
      e.rank = expectation[:rank]
    end

    if !newExpectation.valid?
    end

    if newExpectation.save
      return ReturnObject.new(:ok, "Successfully created Expectation, id: #{newExpectation.id}.", newExpectation)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create expectation. Errors: #{newExpectation.errors}", nil)
    end
  end

  def update_expectation(expectation)
    orgId = expectation[:organization_id]
    expId = expectation[:id]

    dbExpectation = get_expectation(orgId, expId)

    if dbExpectation.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find Expectation with orgId: #{orgId} and expId: #{expId}.", nil)
    end

    # TODO Check title uniqueness within Organization's set of Expectations

    if dbExpectation.update_attributes(:title => expectation[:title],
                                       :description => expectation[:description],
                                       :rank => expectation[:rank])
      return ReturnObject.new(:ok, "Successfully updated Expectation, id: #{dbExpectation.id}.", dbExpectation)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update Expectation, id: #{dbExpectation.id}.", nil)
    end
  end

  def delete_expectation(expectation)
    orgId = expectation[:organization_id]
    expId = expectation[:id]

    dbExpectation = get_expectation(orgId, expId)

    if dbExpectation.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find Expectation with orgId: #{orgId} and expId: #{expId}.", nil)
    end

    if dbExpectation.destroy()
      return ReturnObject.new(:ok, "Successfully deleted Expectation, id: #{dbExpectation.id}.", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete Expectation, id: #{dbExpectation.id}.", nil)
    end
  end

  #################################
  ############# USER ##############
  #################################

  def get_user_expectation(userId, expectationId)
    return UserExpectation.where(:user_id => userId,
                                 :expectation_id => expectationId).first
  end

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
      # TODO
    end

    # TODO Check that expectation_id and user_id belong to the same Organization

    if newUserExpectation.save
      return ReturnObject.new(:ok, "Successfully created UserExpectation, id: #{newUserExpectation.id}.", newUserExpectation)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create UserExpectation.", nil)
    end
  end

  def update_user_expectation(userExpectation)
    userId = userExpectation[:user_id]
    expectationId = userExpectation[:expectation_id]

    dbUserExpectation = get_user_expectation(userId, expectationId)

    if dbUserExpectation.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find UserExpectation with userId: #{userId} and expectationId: #{expectationId}.", nil)
    end

    if dbUserExpectation.update_attributes(:status => userExpectation[:status])
      return ReturnObject.new(:ok, "Successfully updated UserExpectation, id: #{dbUserExpectation.id}.", dbUserExpectation)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update UserExpectation, id: #{dbUserExpectation.id}", nil)
    end
  end

  def delete_user_expectation(userExpectation)
    userId = userExpectation[:user_id]
    expectationId = userExpectation[:expectation_id]

    dbUserExpectation = get_user_expectation(userId, expectationId)

    if dbUserExpectation.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find UserExpectation with userId: #{userId} and expectationId: #{expectationId}.", nil)
    end

    if dbUserExpectation.destroy()
      return ReturnObject.new(:ok, "Successfully deleted UserExpectation, id: #{dbUserExpectation.id}.", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete UserExpectation, id: #{dbUserExpectation.id}.", nil)
    end
  end

end
