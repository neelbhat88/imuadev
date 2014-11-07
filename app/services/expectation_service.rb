class ExpectationService

  # Called via :expectation_id, with an :assignees array of
  # {user_expectation_id: user_expectation.id, status: status} hashes, and a
  # :comment to be applied across all user_expectation updates
  def put_expectation_status(params, current_user)
    conditions = Marshal.load(Marshal.dump(params))

    unless conditions[:assignees].nil?
      userExpectationService = UserExpectationService.new
      comment = ( conditions[:comment].nil? ) ? "" : conditions[:comment]
      conditions[:assignees].each do |a|
        user_expectation = { id: a[:user_expectation_id],
                             status: a[:status],
                             comment: comment }
        userExpectationService.update_user_expectation(user_expectation[:id],
                                                       user_expectation,
                                                       current_user)
      end
    end

    return get_expectation_status(params.except(:comment))
  end

  # Called via :expectation_id
  def get_expectation_status(params)
    conditions = Marshal.load(Marshal.dump(params))

    expectationQ = Querier.new(Expectation).select([:id, :title, :description]).where(conditions)
    userExpectationQ = Querier.new(UserExpectation).select([:id, :expectation_id, :status, :user_id]).where(conditions)

    conditions[:user_id] = userExpectationQ.pluck(:user_id)
    userQ = UserQuerier.new.select([:id, :role, :avatar, :class_of, :first_name, :last_name]).where(conditions.slice(:user_id))
    userQ.set_subQueriers([userExpectationQ])

    view = {expectations: expectationQ.view,
            users: userQ.view}

    return ReturnObject.new(:ok, "Expectation status for expectation_id: #{params[:expectation_id]}.", view)
  end

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
      userExpectationService = UserExpectationService.new
      userQ = UserQuerier.new.select([], [:id]).where({organization_id: newExpectation[:organization_id], role: Constants.UserRole[:STUDENT]})
      userQ.pluck(:id).each do |user_id|
        # This is pretty gross/inefficient, but it shouldn't be called very often
        userExpectationService.update_user_expectations(user_id)
      end
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
