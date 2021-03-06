# Includes Assignment data with the UserAssignment

class ViewUserAssignment

  def initialize(userAssignment, options = {})

    @id = userAssignment.id
    @user_id = userAssignment.user_id
    @assignment_id = userAssignment.assignment_id
    @status = userAssignment.status
    @created_at = userAssignment.created_at
    @updated_at = userAssignment.updated_at

    if options[:user]
      @user = ViewUser.new(userAssignment.user)
    end

    if options[:assignment]
      @assigner = ViewUser.new(userAssignment.assignment.assignment_owner) unless userAssignment.assignment.assignment_owner_type != "User"
      @title = userAssignment.assignment.title
      @description = userAssignment.assignment.description
      @due_datetime = userAssignment.assignment.due_datetime
    end
  end

end
