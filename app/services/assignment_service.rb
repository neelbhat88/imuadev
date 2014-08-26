class AssignmentService

  ###################################
  ########### ASSIGNMENT ############
  ###################################

  def get_assignment(assignmentId)
    return Assignment.where(:id => assignmentId).first
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
      return ReturnObject.new(:internal_server_error, "Failed to create assignment. Errors: #{newAssignment.errors}", nil)
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
      return ReturnObject.new(:internal_server_error, "Failed to update Assignment, id: #{dbAssignment.id}.", nil)
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
      return ReturnObject.new(:internal_server_error, "Failed to delete Assignment, id: #{dbAssignment.id}.", nil)
    end
  end

  ############################################
  ############# USER ASSIGNMENT ##############
  ############################################

  def get_user_assignment(userAssignmentId)
    return UserAssignment.where(:id => userAssignmentId).first
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
      return ReturnObject.new(:internal_server_error, "Failed to create UserAssignment.", nil)
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
      return ReturnObject.new(:internal_server_error, "Failed to update UserAssignment, id: #{dbUserAssignment.id}", nil)
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
      return ReturnObject.new(:internal_server_error, "Failed to delete UserAssignment, id: #{dbUserAssignment.id}.", nil)
    end
  end

end
