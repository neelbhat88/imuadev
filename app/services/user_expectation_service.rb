class UserExpectationService

  def get_user_expectation(user_expectation_id)
    # Use includes to get the expectation with the user_expectation
    user_expectation = UserExpectation.includes(:expectation).find(user_expectation_id)

    return DomainUserExpectation.new({:user_expectation => user_expectation,
                                      :expectation => user_expectation.expectation
                                      })
  end

  def update_user_expectations(userId)
    user = UserRepository.new.get_user(userId)
    user_expectations = UserExpectation.where(:user_id => userId)
    expectations = ExpectationService.new.get_expectations(user.organization_id)

    # Create user_expectations that have not been created
    missing_user_expectations = []
    expectations.each do |e|
      if user_expectations.select{|ue| ue.expectation_id == e.id}.length == 0
        missing_user_expectations << e
      end
    end

    missing_user_expectations.each do |expectation|
      user_expectation = UserExpectation.new do | ue |
        ue.user_id = userId
        ue.expectation_id = expectation.id
        ue.status = Constants.ExpectationStatus[:MEETING]
      end
      if user_expectation.save
        user_expectations << user_expectation
      end
    end
  end

  def get_and_create_user_expectations(userId)
    user = UserRepository.new.get_user(userId)
    user_expectations = UserExpectation.where(:user_id => userId)
    expectations = ExpectationService.new.get_expectations(user.organization_id)

    # Return if all user_expectations have been created already
    if user_expectations.length == expectations.length
      return user_expectations.map{|ue| DomainUserExpectation.new({:user_expectation => ue})}
    end

    # Create user_expectations that have not been created
    missing_user_expectations = []
    expectations.each do |e|
      if user_expectations.select{|ue| ue.expectation_id == e.id}.length == 0
        missing_user_expectations << e
      end
    end

    missing_user_expectations.each do |expectation|
      user_expectation = UserExpectation.new do | ue |
        ue.user_id = userId
        ue.expectation_id = expectation.id
        ue.status = Constants.ExpectationStatus[:MEETING]
      end

      if user_expectation.save
        user_expectations << user_expectation
      end
    end

    return user_expectations.map{|ue| DomainUserExpectation.new({:user_expectation => ue})}
  end

  def update_user_expectation(user_expectation_id, userExpectation, current_user, caller_type = "default")
    dbUserExpectation = UserExpectation.find(user_expectation_id)

    if dbUserExpectation.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find UserExpectation with id: #{user_expectation_id} ")
    end

    initialExpectation = Marshal.load(Marshal.dump(dbUserExpectation))

    previousStatus = dbUserExpectation.status
    if dbUserExpectation.update_attributes(:status => userExpectation[:status],
                                           :comment => userExpectation[:comment],
                                           :modified_by_id => current_user.id,
                                           :modified_by_name => current_user.full_name)


      domainUserExpectation = get_user_expectation(dbUserExpectation.id)

      send_expectation_update(domainUserExpectation, current_user)

      UserExpectationHistoryService.new.create_expectation_history(initialExpectation, current_user)

      event_name = case caller_type
        when "bulk" then :updated_expectation_bulk
        when "default" then :updated_expectation
        else :updated_expectation_other
      end
      IntercomProvider.new.create_event(AnalyticsEventProvider.events[event_name], current_user.id,
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

  def send_expectation_update(user_expectation, modifier)
    Background.process do
      student = UserRepository.new.get_user(user_expectation.user_id)
      relationships = Relationship.where(:user_id => student.id)
      mentors = []

      relationships.each do | r |
        mentor = UserRepository.new.get_user(r.assigned_to_id)
        mentors << mentor
      end

      expectation = Expectation.find(user_expectation.expectation_id)

      ExpectationMailer.changed_user_expectation(student, mentors, modifier, user_expectation, expectation).deliver
    end

  end

end
