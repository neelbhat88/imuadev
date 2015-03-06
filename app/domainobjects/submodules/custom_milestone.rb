class CustomMilestone < ImuaMilestone

  def initialize(milestone=nil)
    super

    @description = "Custom goal:"
  end

  def has_earned?(user, time_unit_id)
    # User has completed the milestone when all associated tasks have been completed

    # Get all assignments owned by this milestone
    conditions = { assignment_owner_type: "Milestone",
                   assignment_owner_id: @id }
    assignmentQ = Querier.factory(Assignment).select([],[:id]).where(conditions)

    # Convert to task scheme if there are no associated assignments
    # TODO - Case where admin has deleted all associated assignments for a milestone
    # that has already been converted over to the task scheme.
    if assignmentQ.domain.length == 0
      convert_to_task_scheme()
      assignmentQ = Querier.factory(Assignment).select([],[:id]).where(conditions)
    end

    # Get all user_assignments for those assignments, for the given user only
    conditions[:assignment_id] = assignmentQ.pluck(:id)
    conditions[:user_id] = user.id
    userAssignmentQ = Querier.factory(UserAssignment).select([],[:assignment_id, :status]).where(conditions)

    # Cycle through each assignment,
    # find a matching user_assignment,
    # if matching user_assignment is found and its status is 1, continue on to next assignment,
    # otherwise, bail out early and return false.
    @earned = true
    assignmentQ.domain([:id]).each do |a|
      index = -1
      userAssignmentQ.domain([:assignment_id]).each do |ua|
        index += 1
        if ua[:assignment_id] == a[:id]
          break
        end
      end

      if index > -1 && userAssignmentQ.domain([:assignment_id])[index][:status] == 1
        userAssignmentQ.domain([:assignment_id]).delete_at(index)
      else
        @earned = false
        break
      end
    end

    return @earned
  end

  def convert_to_task_scheme()
    Rails.logger.debug("***** Converting milestone #{@id} to task scheme *****")

    # Get all applicable users (everyone in the milestone's time_unit_id)
    userQ = Querier.factory(User).select([],[:id]).where({ time_unit_id: @time_unit_id })
    # Get any applicable user_milestones (any that exist for this milestone)
    conditions = { user_id: userQ.pluck(:id), milestone_id: @id }
    userMilestoneQ = Querier.factory(UserMilestone).select([],[:user_id]).where(conditions)

    # Sort user_milestones by :user_id
    user_milestones = userMilestoneQ.domain([:user_id])

    # Go through each user, in order of id.
    # If the next user_milestone in line belongs to this user, then
    # shift out the user_milestone and create a user_assignment with status: 1.
    # If the next user_milestone in line does not belong to this user,
    # then create a user_assignment with status: 0.
    user_assignments = []
    userQ.domain([:id]).each do |u|
      if user_milestones.length > 0 && u[:id] == user_milestones[0][:user_id]
        user_assignments << user_milestones.shift
        user_assignments.last[:status] = 1
      else
        user_assignments << { user_id: u[:id], status: 0 }
      end
    end

    assignment = { title: @value,
                   description: "",
                   due_datetime: nil }

    service_params = { assignment_owner_type: "Milestone",
                       assignment_owner_id: @id,
                       assignment: assignment,
                       user_assignments: user_assignments }

    AssignmentService.new(User.SystemUser).create_broadcast(service_params)
  end

  private :convert_to_task_scheme

end
