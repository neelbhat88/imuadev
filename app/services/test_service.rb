class TestService

  #####################################
  ########### ORGANIZATION ############
  #####################################

  def get_org_test(orgId, orgTestId)
    return OrgTest.where(:organization_id => orgId,
                         :id => orgTestId).first
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
      return ReturnObject.new(:internal_server_error, "Failed to create OrgTest. Errors: #{newOrgTest.errors}", nil)
    end
  end

  def update_org_test(orgTest)
    orgId     = orgTest[:organization_id]
    orgTestId = orgTest[:id]

    dbOrgTest = get_org_test(orgId, orgTestId)

    if dbOrgTest.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find OrgTest with orgId: #{orgId} and orgTestId: #{orgTestId}.", nil)
    end

    # TODO Check title uniqueness within Organization's set of OrgTests

    if dbOrgTest.update_attributes(:title => orgTest[:title],
                                   :score_type => orgTest[:score_type],
                                   :description => orgTest[:description])
      return ReturnObject.new(:ok, "Successfully updated OrgTest, id: #{dbOrgTest.id}.", dbOrgTest)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update OrgTest, id: #{dbOrgTest.id}.", nil)
    end
  end

  def delete_org_test(orgTest)
    orgId     = orgTest[:organization_id]
    orgTestId = orgTest[:id]

    dbOrgTest = get_org_test(orgId, orgTestId)

    if dbOrgTest.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find OrgTest with orgId: #{orgId} and orgTestId: #{orgTestId}.", nil)
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

  def get_user_test(userId, orgTestId)
    return UserTest.where(:user_id => userId,
                          :org_test_id => orgTestId).first
  end

  def get_user_tests(userId)
    return UserTest.where(:user_id => userId)
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

    # TODO Check that org_test_id and user_id belong to the same Organization

    if newUserTest.save
      return ReturnObject.new(:ok, "Successfully created UserTest, id: #{newUserTest.id}.", newUserTest)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create UserTest.", nil)
    end
  end

  def update_user_test(userTest)
    userId      = userTest[:user_id]
    orgTestId   = userTest[:org_test_id]
    timeUnitId  = userTest[:time_unit_id]
    date        = userTest[:date]
    score       = userTest[:score]
    description = userTest[:description]

    dbUserTest = get_user_test(userId, orgTestId)

    if dbUserTest.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find UserTest with userId: #{userId} and orgTestId: #{orgTestId}.", nil)
    end

    if dbUserTest.update_attributes(:status => userTest[:status])
      return ReturnObject.new(:ok, "Successfully updated UserTest, id: #{dbUserTest.id}.", dbUserTest)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update UserTest, id: #{dbUserTest.id}", nil)
    end
  end

  def delete_user_test(userTest)
    userId    = userTest[:user_id]
    orgTestId = userTest[:org_test_id]

    dbUserTest = get_user_test(userId, orgTestId)

    if dbUserTest.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find UserTest with userId: #{userId} and orgTestId: #{orgTestId}.", nil)
    end

    if dbUserTest.destroy()
      return ReturnObject.new(:ok, "Successfully deleted UserTest, id: #{dbUserTest.id}.", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete UserTest, id: #{dbUserTest.id}.", nil)
    end
  end

end
