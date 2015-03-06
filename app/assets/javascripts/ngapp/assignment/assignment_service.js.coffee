angular.module('myApp')
.service 'AssignmentService', ['$http', '$q', ($http, $q) ->

# "Assignment" is owned by the assigner.
# "UserAssignment" is owned by the assignee(s).
#
# "Broadcast" and "Collect" include the associated
# UserAssignments with the parent Assignment object.

  self = this

  today = new Date().getTime()
  two_days_from_now = today + (1000*60*60*24*2) # Two days from now

  @isComplete = (assignment) ->
    return _.every(assignment.user_assignments, (a) -> a.status == 1)

  @incompleteAssignments = (assignments) ->
    if !assignments then return
    incomplete_list = []
    for assignment in assignments
      if !self.isComplete(assignment) then incomplete_list.push(assignment)
    return incomplete_list

  @completedAssignments = (assignments) ->
    if !assignments then return
    complete_list = []
    for assignment in assignments
      if self.isComplete(assignment) then complete_list.push(assignment)
    return complete_list

  @isPastDue = (assignment) ->
    if !assignment.due_datetime
      return false
    due_date = new Date(assignment.due_datetime).getTime()
    return due_date < today

  @isDueSoon = (assignment) ->
    if !assignment.due_datetime
      return false
    due_date = new Date(assignment.due_datetime).getTime()
    return !self.isPastDue(assignment) && due_date <= two_days_from_now

  @created_by_str = (assignment, current_user) ->
    ret = "Unknown"
    switch assignment.assignment_owner_type
      when "User"
        ret = assignment.user.first_last_initial
        if assignment.assignment_owner_id == current_user.id
          ret = "Me"
      when "Milestone"
        ret = "Milestone " + String(assignment.milestone.id)
    return ret

  @parseTaskAssignableUsersTasks = (org) ->
    for a in org.assignments
      switch a.assignment_owner_type
        when "User"
          a.user = _.find(org.users, (u) -> a.assignment_owner_id == u.id)
          if a.user.assignments == undefined
            a.user.assignments = []
          a.user.assignments.push(a)
        when "Milestone"
          a.milestone = _.find(org.milestones, (m) -> a.assignment_owner_id == m.id)
          if a.milestone.assignments == undefined
            a.milestone.assignments = []
          a.milestone.assignments.push(a)
      a.user_assignments = []

    for ua in org.user_assignments
      ua.user = _.find(org.users, (u) -> ua.user_id == u.id)
      if ua.user.user_assignments == undefined
        ua.user.user_assignments = []
      ua.user.user_assignments.push(ua)
      ua.assignment = _.find(org.assignments, (a) -> ua.assignment_id == a.id)
      ua.assignment.user_assignments.push(ua)

    return org


  @_ownerTypeToRoute = (type) ->
    switch type
      when "User" then return "users"
      when "Milestone" then return "milestone"
    return type

  @setUserAssignmentStatus = (user_assignment, status) ->
    new_user_assignment = @newUserAssignment(user_assignment.user_id, user_assignment.assignment_id)
    new_user_assignment.id = user_assignment.id
    new_user_assignment.status = status

    defer = $q.defer()
    @saveUserAssignment(new_user_assignment)
      .success (data) ->
        user_assignment.status = data.user_assignment.status
        user_assignment.updated_at = data.user_assignment.updated_at
        defer.resolve(user_assignment)
    defer.promise

  @getAssignmentCollection = (assignmentId) ->
    $http.get "api/v1/assignment/#{assignmentId}/collection"

  @getTaskAssignableUsers = (ownerType, ownerId) ->
    route = self._ownerTypeToRoute(ownerType)
    $http.get "/api/v1/#{route}/#{ownerId}/get_task_assignable_users"

  @getTaskAssignableUsersTasks = (ownerType, ownerId) ->
    route = self._ownerTypeToRoute(ownerType)
    $http.get "/api/v1/#{route}/#{ownerId}/get_task_assignable_users_tasks"

  @broadcastAssignment = (assignment, userIds) ->
    user_assignments = _.map(userIds, (userId) -> self.newUserAssignment(userId, assignment.id))
    if assignment.id
      $http.put "api/v1/assignment/#{assignment.id}/broadcast",
        { assignment: assignment, user_assignments: user_assignments }
    else
      route = self._ownerTypeToRoute(assignment.assignment_owner_type)
      $http.post "api/v1/#{route}/#{assignment.assignment_owner_id}/create_assignment_broadcast",
        { assignment: assignment, user_assignments: user_assignments }

  @collectUserAssignment = (userAssignmentId) ->
    $http.get "api/v1/user_assignment/#{userAssignmentId}/collect"

  @collectUserAssignments = (userId) ->
    $http.get "api/v1/users/#{userId}/user_assignment/collect"

  ###################################
  ########### ASSIGNMENT ############
  ###################################

  @newAssignment = (ownerType, ownerId) ->
    assignment_owner_type: ownerType,
    assignment_owner_id:   ownerId,
    title:                 "",
    description:           "",
    due_datetime:          null

  @getAssignment = (assignmentId) ->
    $http.get "api/v1/assignment/#{assignmentId}"

  @getAssignments = (ownerType, ownerId) ->
    route = self._ownerTypeToRoute(ownerType)
    $http.get "/api/v1/#{route}/#{ownerId}/assignments"

  @saveAssignment = (assignment) ->
    if assignment.id
      $http.put "/api/v1/assignment/#{assignment.id}", {assignment: assignment}
    else
      route = self._ownerTypeToRoute(assignment.assignment_owner_type)
      $http.post "/api/v1/#{route}/#{assignment.assignment_owner_id}/assignment", {assignment: assignment}

  @deleteAssignment = (assignmentId) ->
    $http.delete "/api/v1/assignment/#{assignmentId}"

  ############################################
  ############# USER ASSIGNMENT ##############
  ############################################

  @newUserAssignment = (userId, assignmentId) ->
    user_id:        userId,
    assignment_id:  assignmentId,
    status:         0

  @getUserAssignments = (userId) ->
    $http.get "/api/v1/users/#{userId}/user_assignment"

  @saveUserAssignment = (userAssignment) ->
    if userAssignment.id
      $http.put "/api/v1/user_assignment/#{userAssignment.id}", {user_assignment: userAssignment}
    else
      $http.post "/api/v1/users/#{userAssignment.user_id}/user_assignment", {user_assignment: userAssignment}

  @deleteUserAssignment = (userAssignmentId) ->
    $http.delete "/api/v1/user_assignment/#{userAssignmentId}"

  @
]
