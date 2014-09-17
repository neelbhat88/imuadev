angular.module('myApp')
.controller 'UserAssignmentController', ['$scope', '$route', 'current_user', 'user_assignment', 'AssignmentService', 'UsersService', 'OrganizationService',
  ($scope, $route, current_user, user_assignment, AssignmentService, UsersService, OrganizationService) ->

    $scope._ = _
    $scope.today = new Date().getTime()
    $scope.two_days_ago = $scope.today - (1000*60*60*24*2) # Two days ago

    $scope.current_user = current_user
    $scope.user_assignment = user_assignment
    # $scope.assigner = $scope.user_assignment.assigner

    $('input, textarea').placeholder()

    $scope.setUserAssignmentStatus = (user_assignment, status) ->
      new_user_assignment = AssignmentService.newUserAssignment(user_assignment.user_id, user_assignment.assignment_id)
      new_user_assignment.id = user_assignment.id
      new_user_assignment.status = status

      AssignmentService.saveUserAssignment(new_user_assignment)
        .success (data) ->
          user_assignment.status = data.user_assignment.status
          user_assignment.updated_at = data.user_assignment.updated_at

    $scope.isPastDue = (user_assignment) ->
      return new Date(user_assignment.due_datetime).getTime() >= $scope.today

    $scope.isDueSoon = (user_assignment) ->
      return !isPastDue(user_assignment) && new Date(user_assignment.due_datetime).getTime() >= $scope.two_days_ago

]
