class CustomMilestone < ImuaMilestone

  def initialize(milestone=nil)
    super

    @description = "Custom goal:"
  end

  def has_earned?(user, time_unit_id)
    # Get all assignments owned by this milestone (if any)
    conditions = { assignment_owner_type: "Milestone",
                   assignment_owner_id: @id }
    assignmentQ = Querier.factory(Assignment).select([],[:id]).where(conditions)

    # Get all user_assignments for those assignments, for the given user only
    conditions[:assignment_id] = assignmentQ.pluck(:id)
    conditions[:user_id] = user.id
    userAssignmentQ = Querier.factory(UserAssignment).select([],[:assignment_id, :status]).where(conditions)

    # Cycle through each assignment,
    # find a matching user_assignment,
    # if matching user_assignment is found and its status is 1,
    # continue on to next assignment,
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

end
