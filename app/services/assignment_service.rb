class AssignmentService

  def initialize(current_user)
    @current_user = current_user
  end

  # Creates an assignment with all associated user_assignments, all at once.
  # Expected to be called via :assignment_owner_type + :assignment_owner_id,
  # with :assignment and :user_assignments parameters
  def create_broadcast(params)
    assignmentResult = _create(params)
    return assignmentResult unless assignmentResult.status == :ok

    params[:assignment_id] = assignmentResult.object.id

    userAssignments = []
    unless params[:user_assignments].nil?
      params[:user_assignments].each do |ua|
        ua[:assignment_id] = params[:assignment_id]
        conditions = { user_assignment: ua, recalculate: false }
        userAssignmentResult = create_user_assignment(conditions)
        if userAssignmentResult.status == :ok
          userAssignments << userAssignmentResult.object
        end
      end
    end

    # TODO - This probs belongs in a MilestonService routine
    if assignmentResult.object.assignment_owner_type == "Milestone"
      conditions = { milestone_id: assignmentResult.object.assignment_owner_id }
      ProgressService.new(@current_user).recalculate_milestones(conditions)
    end

    # Send out emails to all assignees
    send_assignment_emails(@current_user, assignmentResult.object, userAssignments)

    # TODO What if a userAssignment operation fails?
    ret = _get_assignments_view(params.slice(:assignment_id))
    return ReturnObject.new(:ok, "Created Assignment broadcast for assignment_id: #{params[:assignment_id]}.", ret)
  end

  # Updates an assignment and any of its associated user_assignments, all at once.
  # Called via :assignment_id
  # Contains "assignment" and "user_assignments" parameter objects
  def update_broadcast(params)
    params[:assignment][:id] = params[:assignment_id].to_i
    assignmentResult = _update(params[:assignment])
    return assignmentResult unless assignmentResult.status == :ok

    params[:assignment_id] = assignmentResult.object.id

    userAssignments = []
    newUserAssignments = []
    unless params[:user_assignments].nil?
      params[:user_assignments].each do |ua|
        ua[:assignment_id] = params[:assignment_id]
        if ua[:id].nil?
          conditions = { user_assignment: ua, recalculate: false }
          user_assignment_result = create_user_assignment(conditions)
          if user_assignment_result.status == :ok
            userAssignments << user_assignment_result.object
            newUserAssignments << user_assignment_result.object
          end
        # ToDo: Commenting out for now since we currently don't allow for broadcast
        # updates of the user_assignment status (e.g. Complete All). When we do, we can
        # bring this back but we need to figure out a better way to send the emails since
        # update_user_assignment will send an email but we don't want to do that in this loop.
        # If its a broadcast and there are multiple assignments being updates, better to
        # send out all the emails at once after its done just like the send_assignment_emails()
        # is doing it.
        # else
        #   user_assignment_result = update_user_assignment(@current_user, ua)
        #
        #   if user_assignment_result.status == :ok
        #     userAssignments << user_assignment_result.object
        #     newUserAssignments << user_assignment_result.object
        #   end
        end
      end
    end

    # TODO - This probs belongs in a MilestonService routine
    if assignmentResult.object.assignment_owner_type == "Milestone"
      conditions = { milestone_id: assignmentResult.object.assignment_owner_id }
      ProgressService.new(@current_user).recalculate_milestones(conditions)
    end

    # Send out emails to all assignees
    send_assignment_emails(@current_user, assignmentResult.object, newUserAssignments)

    # TODO What if a userAssignment operation fails?
    ret = _get_assignments_view(params.slice(:assignment_id))
    return ReturnObject.new(:ok, "Updated Assignment broadcast for assignment_id: #{params[:assignment_id]}.", ret)
  end

  ###################################
  ########### ASSIGNMENT ############
  ###################################

  # Gets an assignment with all its associated user_assignments, users, etc.
  # Expected to be called via :assignment_id
  def get_collection(params)
    ret = _get_assignments_view(params)
    return ReturnObject.new(:ok, "Assignment collection for assignment_id: #{params[:assignment_id]}.", ret)
  end

  # Gets all assignments owned by the object specified by owner_type and id,
  # with all their associated user_assignments, users, etc.
  # Expected to be called via :assignment_owner_type + :assignment_owner_id
  def index(params)
    retObj = _index(params)
    return retObj unless retObj.status == :ok

    params[:assignment_id] = retObj.object
    retObj.object = _get_assignments_view(params)
    return retObj
  end

  # Creates an assignment
  # Expected to be called via :assignment_owner_type + :assignment_owner_id,
  # with an :assignment parameter
  def create(params)
    retObj = _create(params)
    return retObj unless retObj.status == :ok

    params[:assignment_id] = retObj.object.id
    retObj.object = _get_assignments_view(params)
    return retObj
  end


  # Updates an assignment
  def update(assignment)
    retObj = _update(assignment)
    return retObj unless retObj.status == :ok

    params = { assignment_id: retObj.object.id }
    retObj.object = _get_assignments_view(params)
    return retObj
  end

  # Destroys an assignment
  def destroy(assignmentId)
    # TODO - This probs belongs in a MilestonService routine
    dbAssignment = _get_assignment(assignmentId)
    do_milestone_recalculation = dbAssignment.assignment_owner_type == "Milestone"
    owner_id = dbAssignment.assignment_owner_id

    retObj = _destroy(assignmentId)

    # TODO - This probs belongs in a MilestonService routine
    if retObj.status == :ok and do_milestone_recalculation
      conditions = { milestone_id: owner_id }
      ProgressService.new(@current_user).recalculate_milestones(conditions)
    end

    return retObj
  end

# Helper methods - not to be called by controller, prefixed by underscore
private

  def _get_assignment(assignmentId)
    return Assignment.find(assignmentId)
  end

  # Returns array of Assignment indices
  def _index(params)
    conditions = Marshal.load(Marshal.dump(params))

    assignmentQ = Querier.factory(Assignment).select([],[:id]).where(conditions)
    ret = assignmentQ.pluck(:id)

    return ReturnObject.new(:ok, "Assignments for type #{params[:assignment_owner_type]}, id #{params[:assignment_owner_id]}.", ret)
  end

  # Returns newly created ActiveRecord Assignment object
  def _create(params)
    conditions = Marshal.load(Marshal.dump(params))
    owner_object = conditions[:assignment_owner_type].classify.constantize.where(id: conditions[:assignment_owner_id]).first
    assignment = conditions[:assignment]

    newAssignment = Assignment.new do | e |
      e.assignment_owner_type = conditions[:assignment_owner_type]
      e.assignment_owner_id = conditions[:assignment_owner_id]
      e.title = assignment[:title]
      e.description = assignment[:description]
      e.due_datetime = assignment[:due_datetime]
      e.organization_id = owner_object.organization_id
    end

    if !newAssignment.valid?
    end

    if newAssignment.save
      # For now, skip intercom events for Tasks not owned by a User
      if newAssignment.assignment_owner_type == "User"
        IntercomProvider.new.create_event(AnalyticsEventProvider.events[:created_task], newAssignment.assignment_owner_id,
                                                  {:task_id => newAssignment.id,
                                                   :title => newAssignment.title,
                                                   :description => newAssignment.description
                                                  }
                                          )
      end

      return ReturnObject.new(:ok, "Successfully created Assignment, id: #{newAssignment.id}.", newAssignment)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create assignment. Errors: #{newAssignment.errors.inspect}.", nil)
    end
  end

  # Returns newly updated ActiveRecord Assignment object
  def _update(assignment)
    assignmentId = assignment[:id]

    dbAssignment = _get_assignment(assignmentId)

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

  # Does not return any sort of object, just a message
  def _destroy(assignmentId)
    dbAssignment = _get_assignment(assignmentId)

    if dbAssignment.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find Assignment with id: #{assignmentId}.", nil)
    end

    if dbAssignment.destroy()
      return ReturnObject.new(:ok, "Successfully deleted Assignment, id: #{dbAssignment.id}.", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete Assignment, id: #{dbAssignment.id}. Errors: #{dbAssignment.errors.inspect}.", nil)
    end
  end

  # Should be returned by most public AssignmentService methods so that the
  # front gets a consistent and up-to-date list of all the Assignment objects
  # (in case one was since added/updated).
  # Expects :assignment_id to be given (may be an array)
  # Returns a nested hash of hashes/arrays that fits under "organization"
  def _get_assignments_view(params)
    conditions = Marshal.load(Marshal.dump(params))

    assignmentQ = Querier.factory(Assignment).select([:id, :title, :description, :due_datetime, :created_at, :assignment_owner_type, :assignment_owner_id], [:organization_id]).where(conditions)
    conditions[:organization_id] = assignmentQ.pluck(:organization_id)
    conditions[:owner_object_class] = assignmentQ.domain[0][:assignment_owner_type].classify.constantize

    userAssignmentQ = Querier.factory(UserAssignment).select([:id, :assignment_id, :status, :user_id, :updated_at]).where(conditions)

    conditions[:user_id] = (userAssignmentQ.pluck(:user_id)).uniq
    if conditions[:owner_object_class].name == "User"
      conditions[:user_id] = (conditions[:user_id] + assignmentQ.pluck(:assignment_owner_id)).uniq
    else
      conditions[:owner_object_id] = assignmentQ.pluck(:assignment_owner_id).uniq
    end

    userQ = Querier.factory(User).select([:id, :role, :time_unit_id, :avatar, :class_of, :title, :first_name, :last_name]).where(conditions.slice(:user_id))

    view = {}

    if conditions[:owner_object_class].name == "User"
      userQ.set_subQueriers([assignmentQ, userAssignmentQ])
      view = {users: userQ.view}
    else
      userQ.set_subQueriers([userAssignmentQ])
      foreign_key = {conditions[:owner_object_class].name.foreign_key.to_sym => conditions[:owner_object_id]}
      ownerObjQ = Querier.factory(conditions[:owner_object_class]).where(foreign_key)
      ownerObjQ.set_subQueriers([assignmentQ])
      view[:users] = userQ.view
      view[conditions[:owner_object_class].name.underscore.pluralize.to_sym] = ownerObjQ.view
    end

    if conditions[:owner_object_class].name == "Milestone"
      timeUnitQ = Querier.factory(TimeUnit).select([:name, :id], [:organization_id]).where(conditions.slice(:organization_id))
      view[:time_units] = timeUnitQ.view
      view[:enabled_modules] = EnabledModules.new.get_enabled_module_titles(conditions[:organization_id].first.to_i)
    end

    return view
  end

public
  ############################################
  ############# USER ASSIGNMENT ##############
  ############################################

  def collect_user_assignment(userAssignmentId)
    conditions = {}
    conditions[:user_assignment_id] = userAssignmentId

    userAssignmentQ = Querier.factory(UserAssignment).select([:id, :assignment_id, :status, :user_id, :created_at, :updated_at]).where(conditions)

    conditions[:assignment_id] = userAssignmentQ.pluck(:assignment_id)
    assignmentQ = Querier.factory(Assignment).select([:id, :user_id, :title, :description, :due_datetime]).where(conditions.slice(:assignment_id))

    conditions[:user_id] = (userAssignmentQ.pluck(:user_id) + assignmentQ.pluck(:user_id)).uniq
    userQ = Querier.factory(User).select([:id, :role, :avatar, :title, :first_name, :last_name]).where(conditions.slice(:user_id))
    userQ.set_subQueriers([userAssignmentQ, assignmentQ])

    view = {users: userQ.view}

    return ReturnObject.new(:ok, "User Assignment collection for user_assignment_id: #{userAssignmentId}", view)
  end

  def collect_user_assignments(userId)
    return UserAssignment.includes(:assignment => :assignment_owner).where(:user_id => userId)
  end

  def get_user_assignment(userAssignmentId)
    return UserAssignment.find(userAssignmentId)
  end

  def get_user_assignments(userId)
    return UserAssignment.where(:user_id => userId)
  end

  def get_user_assignment_by_user_id_assignment_id(args)
    userId = args[:user_id]
    taskId = args[:task_id]
    return UserAssignment.where(:user_id => userId, :assignment_id => taskId).first
  end

  def create_user_assignment(params)
    newUserAssignment = UserAssignment.new do | e |
      e.user_id = params[:user_assignment][:user_id]
      e.assignment_id = params[:user_assignment][:assignment_id]
      e.status = params[:user_assignment][:status]
    end

    if !newUserAssignment.valid?
      # TODO
    end

    if newUserAssignment.save

      # Default, assume we should attempt perform milestone recalculation
      # TODO - This probs belongs in a MilestonService routine
      if !params.key?(:recalculate) or params[:recalculate] == true
        conditions = { assignment_id: newUserAssignment.assignment_id }
        assignmentQ = Querier.factory(Assignment).select([],[:assignment_owner_type, :assignment_owner_id]).where(conditions)
        if assignmentQ.domain.first[:assignment_owner_type] == "Milestone"
          conditions = { milestone_id: assignmentQ.pluck(:assignment_owner_id),
                         user_id: params[:user_id] }
          ProgressService.new(@current_user).recalculate_milestones(conditions)
        end
      end

      return ReturnObject.new(:ok, "Successfully created UserAssignment, id: #{newUserAssignment.id}.", newUserAssignment)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create UserAssignment. Errors: #{newUserAssignment.errors.inspect}.", nil)
    end
  end

  def update_user_assignment(params)
    userAssignmentId = params[:user_assignment][:id]

    dbUserAssignment = get_user_assignment(userAssignmentId)

    if dbUserAssignment.nil?
      return ReturnObject.new(:internal_server_error, "Failed to find UserAssignment with id: #{userAssignmentId}.", nil)
    end

    if dbUserAssignment.update_attributes(:status => params[:user_assignment][:status])
      dbAssignment = _get_assignment(dbUserAssignment.assignment_id)
      send_task_complete_email(@current_user, dbAssignment, dbUserAssignment)

      # Default, assume we should attempt perform milestone recalculation
      # TODO - This probs belongs in a MilestonService routine
      if !params.key?(:recalculate) or params[:recalculate] == true
        if dbAssignment.assignment_owner_type == "Milestone"
          conditions = { milestone_id: dbAssignment.assignment_owner_id,
                         user_id: dbUserAssignment.user_id }
          ProgressService.new(@current_user).recalculate_milestones(conditions)
        end
      end

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

    dbAssignment = _get_assignment(dbUserAssignment.assignment_id)
    userId = dbUserAssignment.user_id

    if dbUserAssignment.destroy()

      # Default, assume we should attempt perform milestone recalculation
      # TODO - This probs belongs in a MilestonService routine
      if dbAssignment.assignment_owner_type == "Milestone"
        conditions = { milestone_id: dbAssignment.assignment_owner_id,
                       user_id: userId }
        ProgressService.new(@current_user).recalculate_milestones(conditions)
      end

      return ReturnObject.new(:ok, "Successfully deleted UserAssignment, id: #{dbUserAssignment.id}.", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete UserAssignment, id: #{dbUserAssignment.id}. Errors: #{dbUserAssignment.errors.inspect}.", nil)
    end
  end

  # Send out emails to all assigned users
  # Doing this here for now since it'll be better to send out all emails
  # in one background process instead of a separate background process per
  # email. We might have a task being sent out to many users so we don't want to
  # tie up multiple threads while the emails are being sent.
  # Ideally this will be done by adding the email to a DB table or some
  # sort of queue which a background worker picks up to process and send
  def send_assignment_emails(current_user, assignment, user_assignments)
    # Workaround to not send emails for assignments owned by a milestone
    return if assignment.assignment_owner_type != "User"
    assignment[:user_id] = assignment.assignment_owner_id

    Background.process do
      assignor = UserRepository.new.get_user(assignment.user_id)

      user_assignments.each do |ua|
        assignee = UserRepository.new.get_user(ua.user_id)

        # Don't send an email to tasks assigned to yourself
        if current_user.id != assignee.id
          TaskMailer.task_assigned(assignee, assignor, assignment).deliver
        end
      end
    end
  end

  def send_task_complete_email(current_user, assignment, user_assignment)
    # Workaround to not send emails for assignments owned by a milestone
    return if assignment.assignment_owner_type != "User"
    assignment[:user_id] = assignment.assignment_owner_id

    # Don't send an email for updates to tasks assigned to yourself
    return if current_user.id == assignment.user_id && current_user.id == user_assignment.user_id

    Background.process do
      assignor = UserRepository.new.get_user(assignment.user_id)
      assignee = UserRepository.new.get_user(user_assignment.user_id)

      case current_user.id
      when assignor.id # The assignor completed the task
        if user_assignment.status == 0
          TaskMailer.task_incompleted_by_assignor(assignee, assignor, assignment).deliver
        elsif user_assignment.status == 1
          TaskMailer.task_completed_by_assignor(assignee, assignor, assignment).deliver
        end
      when assignee.id # The assignee completed the task
        if user_assignment.status == 0
          TaskMailer.task_incompleted_by_assignee(assignee, assignor, assignment).deliver
        elsif user_assignment.status == 1
          TaskMailer.task_completed_by_assignee(assignee, assignor, assignment).deliver
        end
      else
        # In this case neither the assignee or the assignor changed the task status
        # so an email needs to be sent to the assignor as well as the assignee notifiying
        # them who updated the task
        if user_assignment.status == 0
          TaskMailer.task_incompleted_by_assignor(assignee, current_user, assignment).deliver
          TaskMailer.task_incompleted_by_other(current_user, assignee, assignor, assignment).deliver
        elsif user_assignment.status == 1
          TaskMailer.task_completed_by_assignor(assignee, current_user, assignment).deliver
          TaskMailer.task_completed_by_other(current_user, assignee, assignor, assignment).deliver
        end
      end
    end
  end

end
