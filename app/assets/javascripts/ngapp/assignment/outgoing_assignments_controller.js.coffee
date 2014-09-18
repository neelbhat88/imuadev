angular.module('myApp')
.controller 'OutgoingAssignmentsController', ['$scope', '$route', 'current_user', 'user', 'AssignmentService', 'UsersService', 'OrganizationService',
  ($scope, $route, current_user, user, AssignmentService, UsersService, OrganizationService) ->

    $scope.today = new Date().getTime()
    $scope.two_days_from_now = $scope.today + (1000*60*60*24*2) # Two days from now

    $scope.current_user = current_user
    $scope.user = user
    $scope.outgoing_assignments = []
    $scope.assignable_users = []

    $('input, textarea').placeholder()

    AssignmentService.collectAssignments($scope.user.id)
      .success (data) ->
        $scope.outgoing_assignments = data.assignment_collections
        for assignment in $scope.outgoing_assignments
          assignment.assignees = []
        $scope.loaded_outgoing_assignments = true

    UsersService.getAssignedStudents($scope.user.id)
      .success (data) ->
        $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
        $scope.assignable_users = $scope.organization.students
        $scope.loaded_assignable_users = true


    $scope.editAssignment = (index) ->
      $scope.editing_outgoing_assignments = true
      $scope.outgoing_assignments[index].editing = true
      $scope.outgoing_assignments[index].new_title = $scope.outgoing_assignments[index].title
      $scope.outgoing_assignments[index].new_description = $scope.outgoing_assignments[index].description
      $scope.outgoing_assignments[index].new_due_datetime = $scope.outgoing_assignments[index].due_datetime

    $scope.cancelEditAssignment = (index) ->
      if $scope.outgoing_assignments[index].id
        $scope.outgoing_assignments[index].editing = false
      else
        $scope.outgoing_assignments.splice(index, 1)
      $scope.editing_outgoing_assignments = false

    $scope.saveAssignment = (index) ->
      new_assignment = AssignmentService.newAssignment($scope.user.id)
      new_assignment.id = $scope.outgoing_assignments[index].id
      new_assignment.user_id = $scope.outgoing_assignments[index].user_id
      new_assignment.title = $scope.outgoing_assignments[index].new_title
      new_assignment.description = $scope.outgoing_assignments[index].new_description
      new_assignment.due_datetime = $scope.outgoing_assignments[index].new_due_datetime
      new_assignment.assignees = $scope.outgoing_assignments[index].assignees

      AssignmentService.broadcastAssignment(new_assignment, _.map(new_assignment.assignees, (assignee) -> assignee.id))
        .success (data) ->
          $scope.outgoing_assignments.splice(index, 1)
          saved_assignment = data.assignment_collection
          saved_assignment.assignees = []
          $scope.outgoing_assignments.push(saved_assignment)
          $scope.editing_outgoing_assignments = false

    $scope.addAssignment = () ->
      $scope.editing_outgoing_assignments = true
      blank_assignment = AssignmentService.newAssignment($scope.user.id)
      blank_assignment.assignees = []
      blank_assignment.editing = true
      $scope.outgoing_assignments.push(blank_assignment)

    $scope.deleteAssignment = (index) ->
      if window.confirm "Are you sure you want to delete this assignment?"
        AssignmentService.deleteAssignment($scope.outgoing_assignments[index].id)
          .success (data) ->
            $scope.outgoing_assignments.splice(index, 1)
            $scope.editing_outgoing_assignments = false

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

    $scope.assignmentIsComplete = (assignment) ->
      return _.every(assignment.user_assignments, (a) -> a.status == 1)

    $scope.isPastDue = (assignment) ->
      due_date = new Date(assignment.due_datetime).getTime()
      return due_date < $scope.today

    $scope.isDueSoon = (assignment) ->
      due_date = new Date(assignment.due_datetime).getTime()
      return !this.isPastDue(assignment) && due_date <= $scope.two_days_from_now

]
