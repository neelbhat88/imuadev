# Includes Assignment data with the UserAssignment

class ViewUserAssignment

  def initialize(userAssignment)
    @id = userAssignment.id
    @user_id = userAssignment.user_id
    @assignment_id = userAssignment.assignment_id
    @status = userAssignment.status

    @assigner = ViewUser.new(userAssignment.assignment.user)
    @title = userAssignment.assignment.title
    @description = userAssignment.assignment.description
    @due_datetime = userAssignment.assignment.due_datetime
  end

end
