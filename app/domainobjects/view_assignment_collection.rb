# Includes an Assignment with its collection of UserAssignments

class ViewAssignmentCollection

  def initialize(assignment, options = {})
    @id = assignment.id
    @user_id = assignment.user_id
    @title = assignment.title
    @description = assignment.description
    @due_datetime = assignment.due_datetime
    @created_at = assignment.created_at
    @user_assignments = assignment.user_assignments.map{|a| ViewUserAssignment.new(a, {user: true})}

    # Most recent change to the assignment or any of its user_assignments
    updated_ats = [assignment.updated_at] + assignment.user_assignments.pluck(:updated_at)
    @updated_at = updated_ats.max

    if options[:user]
      @user = ViewUser.new(assignment.user)
    end
  end

end
