angular.module('myApp')
.controller 'IncomingAssignmentsController', ['$scope', '$route', 'current_user', 'user', 'AssignmentService', 'UsersService', 'OrganizationService',
  ($scope, $route, current_user, user, AssignmentService, UsersService, OrganizationService) ->

    $scope._ = _

    $scope.current_user = current_user
    $scope.user = user
    $scope.incoming_assignments = []

    $('input, textarea').placeholder()

    AssignmentService.collectUserAssignments($scope.user.id)
      .success (data) ->
        $scope.incoming_assignments = data.user_assignments
        $scope.loaded_incoming_assignments = true

    $scope.setUserAssignmentStatus = (user_assignment, status) ->
      new_user_assignment = AssignmentService.newUserAssignment(user_assignment.user_id, user_assignment.assignment_id)
      new_user_assignment.id = user_assignment.id
      new_user_assignment.status = status

      AssignmentService.saveUserAssignment(new_user_assignment)
        .success (data) ->
          user_assignment.status = data.user_assignment.status
          user_assignment.updated_at = data.user_assignment.updated_at
]
