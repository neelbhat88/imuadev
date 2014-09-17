class AssignmentService

  def collect_assignment_2(assignmentId, filters = {})
    filters[:assignment_id] = assignmentId

    domainAssignments = AssignmentService.new.get_assignments_2(filters)
    domainUserAssignments = AssignmentService.new.get_user_assignments_2(filters)

    filters[:user_id] = []
    filters[:user_id] << domainAssignments.pluck(:user_id)
    filters[:user_id] << domainUserAssignments.pluck(:user_id)

    domainUsers = UserService.new.get_users(filters)
    domainUsers.each do |u|
      u.assignments = domainAssignments.select{|a| a.user_id == u.id}
      u.user_assignments = domainUserAssignments.select{|ua| ua.user_id == u.id}
    end

    orgOptions = {}
    orgOptions[:users] = domainUsers

    return DomainOrganization.new(nil, orgOptions)
  end

  def collect_assignments_2(userId, filters = {})
    filters[:user_id] = userId

    domainAssignments = AssignmentService.new.get_assignments_2(filters)

    filters = filters.except(:user_id)
    filters[:assignment_id] = domainAssignments.pluck(:id)
    domainUserAssignments = AssignmentService.new.get_user_assignments_2(filters)

    filters[:user_id] = []
    filters[:user_id] << domainAssignments.pluck(:user_id)
    filters[:user_id] << domainUserAssignments.pluck(:user_id)

    domainUsers = UserService.new.get_users(filters)
    domainUsers.each do |u|
      u.assignments = domainAssignments.select{|a| a.user_id == u.id}
      u.user_assignments = domainUserAssignments.select{|ua| ua.user_id == u.id}
    end

    orgOptions = {}
    orgOptions[:users] = domainUsers

    return DomainOrganization.new(nil, orgOptions)
  end

  def collect_assignment(assignmentId)
    return Assignment.includes([{:user_assignments => :user}, :user]).find(assignmentId)
  end

  def collect_assignments(userId)
    return Assignment.includes(:user_assignments => :user).where(:user_id => userId)
  end

  ###################################
  ########### ASSIGNMENT ############
  ###################################

  def get_assignment(assignmentId)
    return Assignment.find(assignmentId)
  end

  def get_assignments(userId)
    return Assignment.where(:user_id => userId)
  end

  def create_assignment(assignment)
    newAssignment = Assignment.new do | e |
      e.user_id = assignment[:user_id]
      e.title = assignment[:title]
      e.description = assignment[:description]
      e.due_datetime = assignment[:due_datetime]
    end

    if !newAssignment.valid?
    end

    if newAssignment.save
      return ReturnObject.new(:ok, "Successfully created Assignment, id: #{newAssignment.id}.", newAssignment)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create assignment. Errors: #{newAssignment.errors.inspect}.", nil)
    end
  end

  def update_assignment(assignment)
    assignmentId = assignment[:id]

    dbAssignment = get_assignment(assignmentId)

    if dbAssignment.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find Assignment with id: #{assignmentId}.", nil)
    end

    if dbAssignment.update_attributes(:title => assignment[:title],
                                      :description => assignment[:description],
                                      :due_datetime => assignment[:due_datetime])
      return ReturnObject.new(:ok, "Successfully updated Assignment, id: #{dbAssignment.id}.", dbAssignment)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update Assignment, id: #{dbAssignment.id}. Errors: #{dbAssignment.errors.inspect}.", nil)
    end
  end

  def delete_assignment(assignmentId)

    dbAssignment = get_assignment(assignmentId)

    if dbAssignment.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find Assignment with id: #{assignmentId}.", nil)
    end

    if dbAssignment.destroy()
      return ReturnObject.new(:ok, "Successfully deleted Assignment, id: #{dbAssignment.id}.", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete Assignment, id: #{dbAssignment.id}. Errors: #{dbAssignment.errors.inspect}.", nil)
    end
  end

  ############################################
  ############# USER ASSIGNMENT ##############
  ############################################

  def collect_user_assignment(userAssignmentId)
    return UserAssignment.includes(:assignment => :user).find(userAssignmentId)
  end

  def collect_user_assignments(userId)
    return UserAssignment.includes(:assignment => :user).where(:user_id => userId)
  end

  def get_user_assignment(userAssignmentId)
    return UserAssignment.find(userAssignmentId)
  end

  def get_user_assignments(userId)
    return UserAssignment.where(:user_id => userId)
  end

  def create_user_assignment(userAssignment)
    newUserAssignment = UserAssignment.new do | e |
      e.user_id = userAssignment[:user_id]
      e.assignment_id = userAssignment[:assignment_id]
      e.status = userAssignment[:status]
    end

    if !newUserAssignment.valid?
      # TODO
    end

    if newUserAssignment.save
      return ReturnObject.new(:ok, "Successfully created UserAssignment, id: #{newUserAssignment.id}.", newUserAssignment)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create UserAssignment. Errors: #{newUserAssignment.errors.inspect}.", nil)
    end
  end

  def update_user_assignment(userAssignment)
    userAssignmentId = userAssignment[:id]

    dbUserAssignment = get_user_assignment(userAssignmentId)

    if dbUserAssignment.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find UserAssignment with id: #{userAssignmentId}.", nil)
    end

    if dbUserAssignment.update_attributes(:status => userAssignment[:status])
      return ReturnObject.new(:ok, "Successfully updated UserAssignment, id: #{dbUserAssignment.id}.", dbUserAssignment)
    else
      return ReturnObject.new(:internal_server_error, "Failed to update UserAssignment, id: #{dbUserAssignment.id}.  Errors: #{dbUserAssignment.errors.inspect}.", nil)
    end
  end

  def delete_user_assignment(userAssignmentId)
    dbUserAssignment = get_user_assignment(userAssignmentId)

    if dbUserAssignment.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find UserAssignment with id: #{userAssignmentId}.", nil)
    end

    if dbUserAssignment.destroy()
      return ReturnObject.new(:ok, "Successfully deleted UserAssignment, id: #{dbUserAssignment.id}.", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete UserAssignment, id: #{dbUserAssignment.id}. Errors: #{dbUserAssignment.errors.inspect}.", nil)
    end
  end

end
