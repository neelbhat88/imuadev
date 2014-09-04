angular.module('myApp')
.controller 'AssignmentController', ['$scope', '$route', 'current_user', 'assignment', 'edit', 'AssignmentService', 'UsersService', 'OrganizationService',
  ($scope, $route, current_user, assignment, edit, AssignmentService, UsersService, OrganizationService) ->

    $scope._ = _

    $scope.current_user = current_user
    $scope.assignment = assignment
    $scope.assignment.editing = edit
    $scope.assignment.assignees = []
    $scope.user = $scope.assignment.user
    $scope.assignable_users = []

    $('input, textarea').placeholder()

    UsersService.getAssignedStudents($scope.user.id)
      .success (data) ->
        $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
        $scope.assignable_users = $scope.organization.students
        $scope.loaded_assignable_users = true

    $scope.editAssignment = () ->
      $scope.assignment.editing = true
      $scope.assignment.new_title = $scope.assignment.title
      $scope.assignment.new_description = $scope.assignment.description
      $scope.assignment.new_due_datetime = $scope.assignment.due_datetime

    $scope.cancelEditAssignment = () ->
      $scope.assignment.editing = false

    $scope.saveAssignment = (index) ->
      new_assignment = AssignmentService.newAssignment($scope.user.id)
      new_assignment.id = $scope.assignment.id
      new_assignment.user_id = $scope.assignment.user_id
      new_assignment.title = $scope.assignment.new_title
      new_assignment.description = $scope.assignment.new_description
      new_assignment.due_datetime = $scope.assignment.new_due_datetime
      new_assignment.assignees = $scope.assignment.assignees

      AssignmentService.broadcastAssignment(new_assignment, _.map(new_assignment.assignees, (assignee) -> assignee.id))
        .success (data) ->
          saved_assignment = data.assignment_collection
          saved_assignment.assignees = []
          $scope.assignment = saved_assignment
          $scope.assignment.editing = false

    $scope.deleteAssignment = (index) ->
      if window.confirm "Are you sure you want to delete this assignment?"
        AssignmentService.deleteAssignment($scope.assignment.id)
          .success (data) ->
            # TODO What to do here?
            # $scope.assignment = null
            $scope.assignment.editing = false

    $scope.assignAssignee = (user, assignment) ->
      assignment.assignees.push(user)

    $scope.unassignAssignee = (user, assignment) ->
      assignment.assignees = _.without(assignment.assignees, user)

    $scope.setUserAssignmentStatus = (user_assignment, status) ->
      new_user_assignment = AssignmentService.newUserAssignment(user_assignment.user_id, user_assignment.assignment_id)
      new_user_assignment.id = user_assignment.id
      new_user_assignment.status = status

      AssignmentService.saveUserAssignment(new_user_assignment)
        .success (data) ->
          user_assignment.status = data.user_assignment.status
          user_assignment.updated_at = data.user_assignment.updated_at

    $scope.deleteUserAssignment = (assignment, user_assignment) ->
      if window.confirm "Are you sure you want to delete this user's assignment?"
        AssignmentService.deleteUserAssignment(user_assignment.id)
          .success (data) ->
            assignment.user_assignments = _.without(assignment.user_assignments, user_assignment)

    $scope.isAssignable = (assignment, user) ->
      return !_.contains(_.pluck(assignment.user_assignments, 'user_id'), user.id) &&
             !_.contains(_.pluck(assignment.assignees, 'id'), user.id)

]
