angular.module('myApp')
.controller 'AssignmentsController', ['$scope', '$route', 'current_user', 'user', 'AssignmentService', 'UsersService', 'OrganizationService',
  ($scope, $route, current_user, user, AssignmentService, UsersService, OrganizationService) ->

    # $scope.$on 'assignments_nav_selected', (event, assignments_filter) ->
    #   $scope.list_assignments = assignments_filter

    # $scope.$on 'assignments_list_selected', (event, assignment) ->
    #   window.location.href = "#/assignment/" + assignment.id

    $scope.today = new Date().getTime()
    $scope.two_days_from_now = $scope.today + (1000*60*60*24*2) # Two days from now

    $scope.current_user = current_user
    $scope.user = user

    $('input, textarea').placeholder()

    AssignmentService.getTaskAssignableUsersTasks($scope.user.id)
      .success (data) ->
        $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
        $scope.user = _.find($scope.organization.users, (u) -> u.id == $scope.user.id)
        $scope.assignments = $scope.organization.assignments

        $scope.users_assignments = $scope.user.assignments
        $scope.users_user_assignments = _.filter($scope.assignments, (a) -> _.contains(_.pluck($scope.user.user_assignments, 'assignment_id'), a.id))
        $scope.student_assignments = $scope.assignments

        $scope.list_assignments = $scope.users_user_assignments

        $scope.loaded_data = true

    $scope.selectNav = (assignments_filter) ->
      switch assignments_filter
        when 'Tasks Assigned to Me'
          $scope.list_assignments = $scope.users_user_assignments
        when 'Tasks Ive Assigned to Others'
          $scope.list_assignments = $scope.users_assignments
        when 'Tasks Assigned to My Students'
          $scope.list_assignments = $scope.student_assignments

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
