angular.module('myApp')
.controller 'OutgoingAssignmentsController', ['$scope', '$route', 'current_user', 'user', 'AssignmentService', 'UsersService', 'OrganizationService',
  ($scope, $route, current_user, user, AssignmentService, UsersService, OrganizationService) ->

    $scope.today = new Date().getTime()
    $scope.two_days_from_now = $scope.today + (1000*60*60*24*2) # Two days from now

    $scope.current_user = current_user
    $scope.user = user
    $scope.outgoing_assignments = []

    $('input, textarea').placeholder()

    AssignmentService.getTaskAssignableUsersTasks($scope.user.id)
      .success (data) ->
        $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
        $scope.outgoing_assignments = $scope.organization.assignments
        $scope.loaded_outgoing_assignments = true

    AssignmentService.collectAssignments($scope.user.id)
      .success (data) ->
        $scope.outgoing_assignments = data.assignment_collections
        for assignment in $scope.outgoing_assignments
          assignment.assignees = []
        $scope.loaded_outgoing_assignments = true

    $scope.isComplete = (assignment) ->
      return _.every(assignment.user_assignments, (a) -> a.status == 1)

    $scope.isPastDue = (assignment) ->
      if !assignment.due_datetime
        return false
      due_date = new Date(assignment.due_datetime).getTime()
      return due_date < $scope.today

    $scope.isDueSoon = (assignment) ->
      if !assignment.due_datetime
        return false
      due_date = new Date(assignment.due_datetime).getTime()
      return !this.isPastDue(assignment) && due_date <= $scope.two_days_from_now

    $scope.sortIncompleteAssignments = (assignment) ->
      not_dated = _.filter($scope.outgoing_assignments, (a) -> !a.due_datetime)
      not_dated_order = _.sortBy(not_dated, (a) -> a.created_at).reverse()
      dated = _.filter($scope.outgoing_assignments, (a) -> a.due_datetime)
      dated_order = _.sortBy(dated, (a) -> a.due_datetime)
      final_order = dated_order.concat(not_dated_order)
      return _.indexOf(final_order, assignment)

    $scope.sortCompletedAssignments = (assignment) ->
      final_order = _.sortBy($scope.outgoing_assignments, (a) -> if !a.due_datetime then a.updated_at else a.due_datetime).reverse()
      return _.indexOf(final_order, assignment)
]
