angular.module('myApp')
.controller 'AssignmentsController',
['$scope', '$route', '$location', 'current_user', 'user', 'AssignmentService', 'UsersService', 'OrganizationService',
  ($scope, $route, $location, current_user, user, AssignmentService, UsersService, OrganizationService) ->

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

        $scope.selectNav($scope.CONSTANTS.TASK_NAV.assigned_to_me)

        $scope.loaded_data = true

    $scope.viewTask  = (assignment) ->
      if $scope.selected_task_list == $scope.CONSTANTS.TASK_NAV.assigned_to_me
        # Go To user_assignment view
        user_assignment = _.findWhere(assignment.user_assignments, {user_id: $scope.current_user.id})
        $location.path("/user_assignment/#{user_assignment.id}")
      else
        $location.path("/assignment/#{assignment.id}")

    $scope.markComplete = (assignment) ->
      user_assignment = _.findWhere(assignment.user_assignments, {user_id: $scope.user.id})
      AssignmentService.setUserAssignmentStatus(user_assignment, 1)
        .then () ->
          console.log(user_assignment)

    $scope.markIncomplete = (assignment) ->
      user_assignment = _.findWhere(assignment.user_assignments, {user_id: $scope.user.id})
      AssignmentService.setUserAssignmentStatus(user_assignment, 0)
        .then () ->
          console.log(user_assignment)

    $scope.incompleteAssignments = () ->
      if !$scope.list_assignments then return

      incomplete_list = []
      for assignment in $scope.list_assignments
        if !$scope.isComplete(assignment) then incomplete_list.push(assignment)

      return incomplete_list

    $scope.completedAssignments = () ->
      if !$scope.list_assignments then return

      complete_list = []
      for assignment in $scope.list_assignments
        if $scope.isComplete(assignment) then complete_list.push(assignment)

      return complete_list

    $scope.selectNav = (task_list) ->
      $scope.selected_task_list = task_list

      switch task_list
        when $scope.CONSTANTS.TASK_NAV.assigned_to_me
          $scope.list_assignments = $scope.users_user_assignments
          $scope.selected_task_list_title = $scope.CONSTANTS.TASK_NAV.assigned_to_me
        when $scope.CONSTANTS.TASK_NAV.assigned_by_me
          $scope.list_assignments = $scope.users_assignments
          $scope.selected_task_list_title = $scope.CONSTANTS.TASK_NAV.assigned_by_me
        when $scope.CONSTANTS.TASK_NAV.assigned_to_others
          $scope.list_assignments = $scope.student_assignments
          if $scope.current_user.is_org_admin
            $scope.selected_task_list_title = "All Tasks"
          else
            $scope.selected_task_list_title = $scope.CONSTANTS.TASK_NAV.assigned_to_others

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
      not_dated = _.filter($scope.list_assignments, (a) -> !a.due_datetime)
      not_dated_order = _.sortBy(not_dated, (a) -> a.created_at).reverse()
      dated = _.filter($scope.list_assignments, (a) -> a.due_datetime)
      dated_order = _.sortBy(dated, (a) -> a.due_datetime)
      final_order = dated_order.concat(not_dated_order)
      return _.indexOf(final_order, assignment)

    $scope.sortCompletedAssignments = (assignment) ->
      final_order = _.sortBy($scope.list_assignments, (a) -> if !a.due_datetime then a.updated_at else a.due_datetime).reverse()
      return _.indexOf(final_order, assignment)
]
