# TODO - Move existing UserRepository functions into here

class UserService

  def initialize(current_user)
    @current_user = current_user
  end

  # Gets all users that the given user_id is able to assign a task to.
  # Called via :user_id
  def get_task_assignable_users(params)
    conditions = Marshal.load(Marshal.dump(params))

    userQ = Querier.factory(User).select([], [:role, :organization_id]).where(conditions.slice(:user_id))
    conditions[:organization_id] = userQ.domain[0][:organization_id]

    if userQ.domain[0][:role] == Constants.UserRole[:ORG_ADMIN]
      userQ = Querier.factory(User).select([:id, :role, :time_unit_id, :avatar, :class_of, :title, :first_name, :last_name], [:organization_id]).where(conditions.slice(:organization_id))
    else
      conditions[:assigned_to_id] = conditions[:user_id]
      relationshipQ = Querier.factory(Relationship).select([], [:user_id]).where(conditions.slice(:assigned_to_id))
      conditions[:user_id] = (relationshipQ.pluck(:user_id) << params[:user_id].to_s).uniq
      userQ = Querier.factory(User).select([:id, :role, :time_unit_id, :avatar, :class_of, :title, :first_name, :last_name], [:organization_id]).where(conditions)
    end

    view = {users: userQ.view}

    return ReturnObject.new(:ok, "Task assignable users for user_id: #{params[:user_id]}.", view)
  end

  # Gets all the tasks of users that the given "user_id" is able to assign tasks to
  # (i.e. gets all the tasks and the minimum number of user objects for
  # displaying all the Tasks on the page).
  # Called via :user_id
  def get_task_assignable_users_tasks(params)
    conditions = Marshal.load(Marshal.dump(params))

    userQ = Querier.factory(User).select([], [:role, :organization_id]).where(conditions.slice(:user_id))
    conditions[:organization_id] = userQ.domain[0][:organization_id]

    if userQ.domain[0][:role] == Constants.UserRole[:ORG_ADMIN]
      userQ = Querier.factory(User).select([]).where(conditions.slice(:organization_id))
      conditions[:user_id] = (userQ.pluck(:id) << params[:user_id].to_s).uniq
    else
      conditions[:assigned_to_id] = conditions[:user_id]
      relationshipQ = Querier.factory(Relationship).select([], [:user_id]).where(conditions.slice(:assigned_to_id))
      conditions[:user_id] = (relationshipQ.pluck(:user_id) << params[:user_id].to_s).uniq
    end

    userAssignmentQ = Querier.factory(UserAssignment).select([:id, :assignment_id, :status, :user_id]).where(conditions)
    conditions[:assignment_id] = userAssignmentQ.pluck(:assignment_id)
    assignmentQ = Querier.factory(Assignment).select([:id, :title, :description, :due_datetime, :created_at]).where(conditions.slice(:assignment_id))

    # We want the list of owner_ids for User-owned Assignments only
    assignmentUserIds = []
    assignmentMilestoneIds = []
    assignmentQ.domain.each do | a |
      case a[:assignment_owner_type]
      when "User" then assignmentUserIds << a[:assignment_owner_id]
      when "Milestone" then assignmentMilestoneIds << a[:assignment_owner_id]
      end
    end

    conditions[:user_id] = (userAssignmentQ.pluck(:user_id) + assignmentUserIds << params[:user_id].to_s).uniq
    userQ = Querier.factory(User).select([:id, :role, :time_unit_id, :avatar, :class_of, :title, :first_name, :last_name], [:organization_id]).where(conditions)

    conditions[:milestone_id] = assignmentMilestoneIds
    milestoneQ = Querier.factory(Milestone).where(conditions)

    view = { users: userQ.view,
             user_assignments: userAssignmentQ.view,
             assignments: assignmentQ.view,
             milestones: milestoneQ.view }

    return ReturnObject.new(:ok, "Task assignable users' tasks for user_id: #{params[:user_id]}.", view)
  end

end
