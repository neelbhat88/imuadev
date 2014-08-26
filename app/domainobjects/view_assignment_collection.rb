# Includes an Assignment with its collection of UserAssignments

class ViewAssignmentCollection

  def initialize(assignment)
    @id = assignment.id
    @user_id = assignment.user_id
    @title = assignment.title
    @description = assignment.description
    @due_datetime = assignment.due_datetime
    @user_assignments = assignment.user_assignments
  end

end
