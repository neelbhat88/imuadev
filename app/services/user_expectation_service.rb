class UserExpectationService

  def initialize(current_user)
    @current_user = current_user
  end

  def get_user_expectation(user_expectation_id)
    # Use includes to get the expectation with the user_expectation
    user_expectation = UserExpectation.includes(:expectation).find(user_expectation_id)

    return DomainUserExpectation.new({:user_expectation => user_expectation,
                                      :expectation => user_expectation.expectation
                                      })
  end

  def create_user_expectation(args)
    userId = args[:user_id]
    expectation_id = args[:expectation_id]
    status = args[:status]
    modified_by_name = args[:modified_by_name]
    modified_by_id = args[:modified_by_id]
    comment = args[:comment]

    user_expectation = UserExpectation.new do | ue |
      ue.user_id = userId
      ue.expectation_id = expectation_id
      ue.status = status
      ue.modified_by_name = modified_by_name
      ue.modified_by_id = modified_by_id
      ue.comment = comment
    end

    if user_expectation.save
      UserExpectationHistoryService.new(@current_user).create_expectation_history(user_expectation)

      return user_expectation
    else
      Rails.logger.error("Error creating user expectation: #{user_expectation.errors.inspect}")
      return nil
    end
  end

  def create_user_expectations(userId)
    user = UserRepository.new.get_user(userId)
    user_expectations = UserExpectation.where(:user_id => userId)
    expectations = ExpectationService.new(@current_user).get_expectations(user.organization_id)

    # Return if all user_expectations have been created already
    if user_expectations.length == expectations.length
      return user_expectations
    end

    # Create user_expectations that have not been created
    missing_user_expectations = []
    expectations.each do |e|
      if user_expectations.select{|ue| ue.expectation_id == e.id}.length == 0
        missing_user_expectations << e
      end
    end

    missing_user_expectations.each do |expectation|
      ue = { :user_id => userId,
             :expectation_id => expectation.id,
             :status => Constants.ExpectationStatus[:MEETING],
             :modified_by_name => User.SystemUser.first_name,
             :modified_by_id => User.SystemUser.id
           }
      user_expectation = create_user_expectation(ue)

      user_expectations << user_expectation unless user_expectation.nil?
    end

    return user_expectations
  end

  def get_and_create_user_expectations(userId)
    user_expectations = create_user_expectations(userId)

    return user_expectations.map{|ue| DomainUserExpectation.new({:user_expectation => ue})}
  end

  def update_user_expectation(user_expectation_id, userExpectation, caller_type = "default")
    dbUserExpectation = UserExpectation.find(user_expectation_id)

    if dbUserExpectation.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find UserExpectation with id: #{user_expectation_id} ")
    end

    previousStatus = dbUserExpectation.status
    if dbUserExpectation.update_attributes(:status => userExpectation[:status],
                                           :comment => userExpectation[:comment],
                                           :modified_by_id => @current_user.id,
                                           :modified_by_name => @current_user.full_name)


      domainUserExpectation = get_user_expectation(dbUserExpectation.id)

      UserExpectationHistoryService.new(@current_user).create_expectation_history(dbUserExpectation)

      event_name = case caller_type
        when "bulk" then :updated_expectation_bulk
        when "default" then :updated_expectation
        else :updated_expectation_other
      end
      IntercomProvider.new.create_event(AnalyticsEventProvider.events[event_name], @current_user.id,
                                                {:user_expectation_id => user_expectation_id,
                                                 :previous_status => previousStatus,
                                                 :new_status => dbUserExpectation.status,
                                                 :comment => dbUserExpectation.comment
                                                }
                                        )

      return ReturnObject.new(:ok, "Successfully updated UserExpectation, id: #{dbUserExpectation.id}.", domainUserExpectation)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update UserExpectation, id: #{dbUserExpectation.id}", nil)
    end
  end

  def update_user_expectation_comment(user_expectation_id, comment)
    dbUserExpectation = UserExpectation.find(user_expectation_id)

    if dbUserExpectation.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find UserExpectation with id: #{user_expectation_id} ")
    end

    if dbUserExpectation.update_attributes(:comment => comment)
      domainUserExpectation = get_user_expectation(dbUserExpectation.id)

      return ReturnObject.new(:ok, "Successfully updated UserExpectation Comment, id: #{dbUserExpectation.id}.", domainUserExpectation)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update UserExpectation Comment, id: #{dbUserExpectation.id}", nil)
    end
  end
end
