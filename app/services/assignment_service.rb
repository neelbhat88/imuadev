class AssignmentService

  # Called via :assignment_id
  def get_assignment_collection(params)
    conditions = Marshal.load(Marshal.dump(params))

    assignmentQ = Querier.new(Assignment).select([:id, :user_id, :title, :description, :due_datetime, :created_at]).where(conditions)
    userAssignmentQ = Querier.new(UserAssignment).select([:id, :assignment_id, :status, :user_id]).where(conditions)

    conditions[:user_id] = (assignmentQ.pluck(:user_id) + userAssignmentQ.pluck(:user_id)).uniq
    userQ = UserQuerier.new.select([:id, :role, :time_unit_id, :avatar, :class_of, :title, :first_name, :last_name]).where(conditions.slice(:user_id))
    userQ.set_subQueriers([assignmentQ, userAssignmentQ])

    view = {users: userQ.view}

    return ReturnObject.new(:ok, "Assignment collection for assignment_id: #{params[:assignment_id]}.", view)
  end

  # Called via :user_id
  # Contains "assignment" and "user_assignments" parameter objects
  def broadcast(params)
    conditions = Marshal.load(Marshal.dump(params))

    conditions[:assignment][:user_id] = conditions[:user_id].to_i
    assignmentResult = create_assignment(conditions[:assignment])
    return assignmentResult unless assignmentResult.status == :ok

    conditions[:assignment_id] = assignmentResult.object.id

    userAssignmentResults = []
    conditions[:user_assignments].each do |ua|
      ua[:assignment_id] = conditions[:assignment_id]
      userAssignmentResults << create_user_assignment(ua)
    end

    # TODO What if a userAssignment operation fails?
    return get_assignment_collection(conditions.slice(:assignment_id))
  end

  # Called via :assignment_id
  # Contains "assignment" and "user_assignments" parameter objects
  def broadcast_update(params)
    conditions = Marshal.load(Marshal.dump(params))

    conditions[:assignment][:id] = conditions[:assignment_id].to_i
    assignmentResult = update_assignment(conditions[:assignment])
    return assignmentResult unless assignmentResult.status == :ok

    conditions[:assignment_id] = assignmentResult.object.id

    userAssignmentResults = []
    conditions[:user_assignments].each do |ua|
      ua[:assignment_id] = conditions[:assignment_id]
      if ua[:id].nil?
        userAssignmentResults << create_user_assignment(ua)
      else
        userAssignmentResults << update_user_assignment(ua)
      end
    end

    # TODO What if a userAssignment operation fails?
    return get_assignment_collection(conditions.slice(:assignment_id))
  end

  # Called via :user_id
  def get_task_assignable_users(params)
    conditions = Marshal.load(Marshal.dump(params))

    userQ = UserQuerier.new.select([], [:role, :organization_id]).where(conditions.slice(:user_id))
    conditions[:organization_id] = userQ.domain[0][:organization_id]

    if userQ.domain[0][:role] == Constants.UserRole[:ORG_ADMIN]
      userQ = UserQuerier.new.select([:id, :role, :time_unit_id, :avatar, :class_of, :title, :first_name, :last_name], [:organization_id]).where(conditions.slice(:organization_id))
    else
      conditions[:assigned_to_id] = conditions[:user_id]
      relationshipQ = Querier.new(Relationship).select([], [:user_id]).where(conditions.slice(:assigned_to_id))
      conditions[:user_id] = (relationshipQ.pluck(:user_id) << params[:user_id].to_s).uniq
      userQ = UserQuerier.new.select([:id, :role, :time_unit_id, :avatar, :class_of, :title, :first_name, :last_name], [:organization_id]).where(conditions)
    end

    view = {users: userQ.view}

    return ReturnObject.new(:ok, "Task assignable users for user_id: #{params[:user_id]}.", view)
  end

  # Called via :user_id
  def get_task_assignable_users_tasks(params)
    conditions = Marshal.load(Marshal.dump(params))

    userQ = UserQuerier.new.select([], [:role, :organization_id]).where(conditions.slice(:user_id))
    conditions[:organization_id] = userQ.domain[0][:organization_id]

    if userQ.domain[0][:role] == Constants.UserRole[:ORG_ADMIN]
      userQ = UserQuerier.new.select([]).where(conditions.slice(:organization_id))
      conditions[:user_id] = (userQ.pluck(:id) << params[:user_id].to_s).uniq
    else
      conditions[:assigned_to_id] = conditions[:user_id]
      relationshipQ = Querier.new(Relationship).select([], [:user_id]).where(conditions.slice(:assigned_to_id))
      conditions[:user_id] = (relationshipQ.pluck(:user_id) << params[:user_id].to_s).uniq
    end

    userAssignmentQ = Querier.new(UserAssignment).select([:id, :assignment_id, :status, :user_id]).where(conditions)
    conditions[:assignment_id] = userAssignmentQ.pluck(:assignment_id)
    assignmentQ = Querier.new(Assignment).select([:id, :user_id, :title, :description, :due_datetime, :created_at]).where(conditions.slice(:assignment_id))
    conditions[:user_id] = (userAssignmentQ.pluck(:user_id) + assignmentQ.pluck(:user_id) << params[:user_id].to_s).uniq

    userQ = UserQuerier.new.select([:id, :role, :time_unit_id, :avatar, :class_of, :title, :first_name, :last_name], [:organization_id]).where(conditions)
    userQ.set_subQueriers([userAssignmentQ, assignmentQ])

    view = {users: userQ.view}

    return ReturnObject.new(:ok, "Task assignable users for user_id: #{params[:user_id]}.", view)
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
      IntercomProvider.new.create_event(AnalyticsEventProvider.events[:created_task], newAssignment.user_id,
                                                {:task_id => newAssignment.id,
                                                 :title => newAssignment.title,
                                                 :description => newAssignment.description
                                                }
                                        )

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
