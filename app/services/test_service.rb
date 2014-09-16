class TestService

  #####################################
  ########### ORGANIZATION ############
  #####################################

  def get_org_test(orgTestId)
    return OrgTest.where(:id => orgTestId).first
  end

  def get_org_tests(orgId)
    return OrgTest.where(:organization_id => orgId)
  end

  def create_org_test(orgTest)
    newOrgTest        = OrgTest.new do | e |
      e.organization_id = orgTest[:organization_id]
      e.title           = orgTest[:title]
      e.score_type      = orgTest[:score_type]
      e.description     = orgTest[:description]
    end

    if !newOrgTest.valid?
    end

    if newOrgTest.save
      return ReturnObject.new(:ok, "Successfully created OrgTest, id: #{newOrgTest.id}.", newOrgTest)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create OrgTest. Errors: #{newOrgTest.errors.inspect}", nil)
    end
  end

  def update_org_test(orgTestId, orgTest)
    dbOrgTest = get_org_test(orgTestId)

    if dbOrgTest.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find OrgTest with id: #{orgTestId}.", nil)
    end

    # TODO Check title uniqueness within Organization's set of OrgTests

    if dbOrgTest.update_attributes(:title       => orgTest[:title],
                                   :score_type  => orgTest[:score_type],
                                   :description => orgTest[:description])
      return ReturnObject.new(:ok, "Successfully updated OrgTest, id: #{dbOrgTest.id}.", dbOrgTest)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update OrgTest, id: #{dbOrgTest.id}.", dbOrgTest.errors.inspect)
    end
  end

  def delete_org_test(orgTestId)
    dbOrgTest = get_org_test(orgTestId)

    if dbOrgTest.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find OrgTest with id: #{orgTestId}.", nil)
    end

    if dbOrgTest.destroy()
      return ReturnObject.new(:ok, "Successfully deleted OrgTest, id: #{dbOrgTest.id}.", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete OrgTest, id: #{dbOrgTest.id}.", nil)
    end
  end

  #################################
  ############# USER ##############
  #################################

  def get_user_test(userTestId)
    return UserTest.where(:id => userTestId).first
  end

  def get_user_tests(userId)
    return UserTest.where(:user_id => userId)
  end

  def get_user_tests_2(filters = {})
    userTests = nil

    if !defined?(filters[:module]) || filters[:module] == Constants.Modules[:TESTING]
      applicable_filters = FilterFactory.new.conditions(UserTest.column_names.map(&:to_sym), filters)
      userTests = UserTest.find(:all, :conditions => applicable_filters)
    end

    return userTests.map{|ut| DomainUserTest.new(ut)} unless userTests.nil?
  end

  def get_user_tests_time_unit(userId, timeUnitId)
    return UserTest.where(:user_id => userId,
                          :time_unit_id => timeUnitId)
  end

  def create_user_test(userTest)
    newUserTest    = UserTest.new do | e |
      e.user_id      = userTest[:user_id]
      e.org_test_id  = userTest[:org_test_id]
      e.time_unit_id = userTest[:time_unit_id]
      e.date         = userTest[:date]
      e.score        = userTest[:score]
      e.description  = userTest[:description]
    end

    if !newUserTest.valid?
      # TODO
    end

    # TODO Check that org_test_id, user_id, and time_unit_id all belong to the same Organization

    if newUserTest.save
      return ReturnObject.new(:ok, "Successfully created UserTest, id: #{newUserTest.id}.", newUserTest)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create UserTest.", newUserTest.errors.insepct)
    end
  end

  def update_user_test(userTestId, userTest)
    dbUserTest = get_user_test(userTestId)

    if dbUserTest.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find UserTest with userTestId: #{userTestId}.", nil)
    end

    if dbUserTest.update_attributes(:org_test_id => userTest[:org_test_id],
                                    :date        => userTest[:date],
                                    :score       => userTest[:score],
                                    :description => userTest[:description])
      return ReturnObject.new(:ok, "Successfully updated UserTest, id: #{dbUserTest.id}.", dbUserTest)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update UserTest, id: #{dbUserTest.id}", dbUserTest.errors.inspect)
    end
  end

  def delete_user_test(userTestId)
    dbUserTest = get_user_test(userTestId)

    if dbUserTest.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find UserTest with id: #{userTestId}.", nil)
    end

    if dbUserTest.destroy()
      return ReturnObject.new(:ok, "Successfully deleted UserTest, id: #{dbUserTest.id}.", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete UserTest, id: #{dbUserTest.id}.", nil)
    end
  end

end
