class AssignmentService

  # Called via :assignment_id
  def collect_assignment_2(params)
    conditions = params

    attributes = []
    assignments = Assignment.find_by_filters(conditions, attributes)

    attributes = []
    userAssignments = UserAssignment.find_by_filters(conditions, attributes)

    conditions[:user_id] = []
    conditions[:user_id] << assignments.pluck(:user_id)
    conditions[:user_id] << userAssignments.pluck(:user_id)

    viewUsers = []
    attributes = []
    User.find_by_filters(conditions, attributes).each do |user|
      userOptions = {}
      userOptions[:user] = user
      userOptions[:assignments] = assignments.select{|a| a.user_id == user.id}.map{|a| ViewAssignment.new({assignment: a})}
      userOptions[:user_assignments] = userAssignments.select{|ua| ua.user_id == user.id}.map{|ua| ViewUserAssignment.new({user_assignment: ua})}
      viewUsers << ViewUser.new(userOptions)
    end

    viewOrg = ViewOrganization.new({users: viewUsers})
    return ReturnObject.new(:ok, "Assignment collection for assignment_id: #{params[:assignment_id]}.", viewOrg)
  end

  # Called via :user_id
  def collect_assignments_2(params)
    conditions = params

    attributes = []
    assignments = Assignment.find_by_filters(conditions, attributes)

    conditions = conditions.except(:user_id)
    conditions[:assignment_id] = assignments.ids
    attributes = []
    userAssignments = UserAssignment.find_by_filters(conditions, attributes)

    conditions[:user_id] = []
    conditions[:user_id] << assignments.pluck(:user_id)
    conditions[:user_id] << userAssignments.pluck(:user_id)

    viewUsers = []
    attributes = []
    User.find_by_filters(conditions, attributes).each do |user|
      userOptions = {}
      userOptions[:user] = user
      userOptions[:assignments] = assignments.select{|a| a.user_id == user.id}.map{|a| ViewAssignment.new({assignment: a})}
      userOptions[:user_assignments] = userAssignments.select{|ua| ua.user_id == user.id}.map{|ua| ViewUserAssignment.new({user_assignment: ua})}
      viewUsers << ViewUser.new(userOptions)
    end

    viewOrg = ViewOrganization.new({users: viewUsers})
    return ReturnObject.new(:ok, "Assignment collections for user_id: #{params[:user_id]}.", viewOrg)
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
