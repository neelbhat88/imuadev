angular.module('myApp')
.controller 'AssignmentsController', ['$scope', '$route', 'current_user', 'user', 'AssignmentService', 'UsersService', 'OrganizationService',
  ($scope, $route, current_user, user, AssignmentService, UsersService, OrganizationService) ->

    $scope.today = new Date().getTime()
    $scope.two_days_from_now = $scope.today + (1000*60*60*24*2) # Two days from now

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

    $scope.isComplete = (user_assignment) ->
      return user_assignment.status == 1

    $scope.isPastDue = (user_assignment) ->
      if user_assignment.due_datetime == null
        return false
      due_date = new Date(user_assignment.due_datetime).getTime()
      return due_date < $scope.today

    $scope.isDueSoon = (user_assignment) ->
      if user_assignment.due_datetime == null
        return false
      due_date = new Date(user_assignment.due_datetime).getTime()
      return !this.isPastDue(user_assignment) && due_date <= $scope.two_days_from_now

    $scope.sortIncompleteAssignments = (user_assignment) ->
      not_dated = _.filter($scope.incoming_assignments, (a) -> !a.due_datetime)
      not_dated_order = _.sortBy(not_dated, (a) -> a.created_at).reverse()
      dated = _.filter($scope.incoming_assignments, (a) -> a.due_datetime)
      dated_order = _.sortBy(dated, (a) -> a.due_datetime)
      final_order = dated_order.concat(not_dated_order)
      return _.indexOf(final_order, user_assignment)

    $scope.sortCompletedAssignments = (user_assignment) ->
      final_order = _.sortBy($scope.incoming_assignments, (a) -> if !a.due_datetime then a.updated_at else a.due_datetime).reverse()
      return _.indexOf(final_order, user_assignment)
]
