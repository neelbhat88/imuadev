# Includes an Assignment with its collection of UserAssignments

class ViewAssignmentCollection

  def initialize(assignment)
    @id = assignment.id
    @user_id = assignment.user_id
    @title = assignment.title
    @description = assignment.description
    @due_datetime = assignment.due_datetime
    @created_at = assignment.created_at
    @user_assignments = assignment.user_assignments.map{|a| ViewUserAssignment.new(a, {user: true})}
  end

end
