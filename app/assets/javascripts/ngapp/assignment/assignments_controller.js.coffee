angular.module('myApp')
.controller 'AssignmentsController',
['$scope', '$route', '$location', 'current_user', 'user', 'AssignmentService', 'UsersService', 'OrganizationService',
  ($scope, $route, $location, current_user, user, AssignmentService, UsersService, OrganizationService) ->

    $scope.today = new Date().getTime()
    $scope.two_days_from_now = $scope.today + (1000*60*60*24*2) # Two days from now

    $scope.current_user = current_user
    $scope.user = user

    $('input, textarea').placeholder()

    # Holy shit what is this.
    $scope.clone = (obj, blacklist = []) ->
      copy = null

      # Handle the 3 simple types, and null or undefined
      if obj == null || typeof obj != "object"
        return obj

      # Handle Date
      if obj instanceof Date
        copy = new Date();
        copy.setTime(obj.getTime())
      # Handle Array
      else if obj instanceof Array
        copy = []
        add_blacklist = []
        for i in obj
          given_blacklist = angular.copy(blacklist)
          copy.push($scope.clone(i, given_blacklist))
          add_blacklist += _.difference(given_blacklist, blacklist, add_blacklist)
        blacklist += add_blacklist
      # Handle Object
      else if obj instanceof Object
        copy = {}
        postObjs = []
        for i in Object.keys(obj)
          if obj[i] instanceof Array or obj[i] instanceof Object
            if !_.contains(blacklist, i)
              blacklist.push(i)
              postObjs.push(i)
          else
            copy[i] = obj[i]
        add_blacklist = []
        for i in postObjs
          given_blacklist = angular.copy(blacklist)
          copy[i] = $scope.clone(obj[i], given_blacklist)
          add_blacklist += _.difference(given_blacklist, blacklist, add_blacklist)
        blacklist += add_blacklist
      else
        throw new Error("Unable to copy - obj type isn't supported.")

      return copy

    AssignmentService.getTaskAssignableUsersTasks('User', $scope.user.id)
      .success (data) ->
        $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
        $scope.user = _.find($scope.organization.users, (u) -> u.id == $scope.user.id)
        $scope.assignments = $scope.organization.assignments

        $scope.users_assignments = $scope.clone($scope.user.assignments)
        $scope.users_user_assignments = $scope.clone(_.filter($scope.assignments, (a) -> _.contains(_.pluck($scope.user.user_assignments, 'assignment_id'), a.id)))
        $scope.student_assignments = $scope.clone($scope.assignments)

        selected_nav = $location.search().selected_nav # Reads query string param
        if selected_nav
          $scope.selectNav(selected_nav)
        else
          $scope.selectNav($scope.CONSTANTS.TASK_NAV.assigned_to_me)

        $scope.loaded_data = true

    $scope.viewTask  = (assignment) ->
      if $scope.selected_task_list == $scope.CONSTANTS.TASK_NAV.assigned_to_me
        # Go To user_assignment view
        user_assignment = _.findWhere(assignment.user_assignments, {user_id: $scope.current_user.id})
        $location.path("/user_assignment/#{user_assignment.id}")
        $location.url($location.path()) #Do this to remove query string params
      else
        $location.path("/assignment/#{assignment.id}")
        $location.url($location.path()) #Do this to remove query string params

    $scope.markComplete = (assignment) ->
      user_assignment = _.findWhere(assignment.user_assignments, {user_id: $scope.user.id})
      AssignmentService.setUserAssignmentStatus(user_assignment, 1)
        .then () ->
          # console.log(user_assignment)

    $scope.markIncomplete = (assignment) ->
      user_assignment = _.findWhere(assignment.user_assignments, {user_id: $scope.user.id})
      AssignmentService.setUserAssignmentStatus(user_assignment, 0)
        .then () ->
          # console.log(user_assignment)

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
      $location.search("selected_nav", task_list) #Sets query string param

      switch task_list
        when $scope.CONSTANTS.TASK_NAV.assigned_to_me
          # Use only the user's user_assignments
          assignments = _.map($scope.users_user_assignments, (a) -> a.user_assignments = _.filter(a.user_assignments, (ua) -> ua.user_id == $scope.user.id); a)
          $scope.list_assignments = assignments
          $scope.selected_task_list_title = $scope.CONSTANTS.TASK_NAV.assigned_to_me
        when $scope.CONSTANTS.TASK_NAV.assigned_by_me
          $scope.list_assignments = $scope.users_assignments
          $scope.selected_task_list_title = $scope.CONSTANTS.TASK_NAV.assigned_by_me
        when $scope.CONSTANTS.TASK_NAV.assigned_to_others
          # Don't use any of the user's user_assignments
          assignments = _.map($scope.student_assignments, (a) -> a.user_assignments = _.filter(a.user_assignments, (ua) -> ua.user_id != $scope.user.id); a)
          $scope.list_assignments = _.filter(assignments, (a) -> a.user_assignments.length > 0)
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

    $scope.created_by_str = (assignment) ->
      ret = "Test"
      switch assignment.assignment_owner_type
        when "User"
          ret = assignment.user.first_last_initial
          if assignment.assignment_owner_id == $scope.current_user.id
            ret = "Me"
        when "Milestone"
          ret = "a Milestone"
      return ret
]
