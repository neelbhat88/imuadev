angular.module('myApp')
.service 'AssignmentService', ['$http', '$q', ($http, $q) ->

# "Assignment" is owned by the assigner.
# "UserAssignment" is owned by the assignee(s).
#
# "Broadcast" and "Collect" include the associated
# UserAssignments with the parent Assignment object.

  self = this

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
    $http.get "api/v1/#{users}/#{userId}/user_assignment/collect"

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
