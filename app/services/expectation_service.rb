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

end
