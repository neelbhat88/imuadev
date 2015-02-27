angular.module('myApp')
.controller 'MilestoneController', ['$scope', '$route', '$location', 'current_user', 'milestone_id', 'edit', 'MilestoneService', 'UsersService', 'OrganizationService', 'RoadmapService', 'ProgressService', 'AssignmentService',
  ($scope, $route, $location, current_user, milestone_id, edit, MilestoneService, UsersService, OrganizationService, RoadmapService, ProgressService, AssignmentService) ->

    $scope.milestone_id = milestone_id
    $scope.current_user = current_user
    $scope.new_assignment = AssignmentService.newAssignment('Milestone', $scope.milestone_id)

    $scope.selected_task_list_title = "What's needed to complete this milestone?"

    $scope.recalculateCompletion = () =>
      partition = _.partition($scope.users_total, (u) -> u.user_milestones and u.user_milestones.length > 0)
      $scope.users_complete = partition[0]
      $scope.users_incomplete = partition[1]
      $scope.percent_complete = 0
      $scope.num_students_in_semester = $scope.users_total.length

      if $scope.users_total.length > 0
        $scope.percent_complete = (($scope.users_complete.length / $scope.users_total.length) * 100).toFixed(0)

      if current_user.is_mentor
        $scope.users_complete = _.filter($scope.users_complete, (u) -> _.contains(current_user.assigned_users, u.id))
        $scope.users_incomplete = _.filter($scope.users_incomplete, (u) -> _.contains(current_user.assigned_users, u.id))
        $scope.num_students_in_semester = $scope.users_complete.length + $scope.users_incomplete.length

    MilestoneService.getMilestoneStatus($scope.milestone_id)
      .then (data) ->
        $scope.organization = MilestoneService.parseMilestoneStatus(data.organization)
        $scope.users_total = $scope.organization.students
        $scope.milestone = $scope.organization.milestones[0]
        $scope.milestone.editing = false
        $scope.recalculateCompletion()
        $scope.loaded_data = true

    $scope.milestoneHasTasks = () ->
      return $scope.milestone.submodule == "YesNo"

    $scope.incompleteAssignments = () ->
      return AssignmentService.incompleteAssignments($scope.milestone.assignments)

    $scope.completedAssignments = () ->
      return AssignmentService.completedAssignments($scope.milestone.assignments)

    $scope.isPastDue = (assignment) ->
      return AssignmentService.isPastDue(assignment)

    $scope.isDueSoon = (assignment) ->
      return AssignmentService.isDueSoon(assignment)

    $scope.sortIncompleteAssignments = (assignment) ->
      not_dated = _.filter($scope.milestone.assignments, (a) -> !a.due_datetime)
      not_dated_order = _.sortBy(not_dated, (a) -> a.created_at).reverse()
      dated = _.filter($scope.milestone.assignments, (a) -> a.due_datetime)
      dated_order = _.sortBy(dated, (a) -> a.due_datetime)
      final_order = dated_order.concat(not_dated_order)
      return _.indexOf(final_order, assignment)

    $scope.sortCompletedAssignments = (assignment) ->
      final_order = _.sortBy($scope.milestone.assignments, (a) -> if !a.due_datetime then a.updated_at else a.due_datetime).reverse()
      return _.indexOf(final_order, assignment)

    $scope.created_by_str = (assignment) ->
      return AssignmentService.created_by_str(assignment, $scope.current_user)

    $scope.saveNewAssignment = () ->
      # Always assign all assignable users
      AssignmentService.broadcastAssignment($scope.new_assignment, _.map($scope.users_total, (assignee) -> assignee.id))
        .success (data) ->
          organization = OrganizationService.parseOrganizationWithUsers(data.organization)
          saved_assignment =  organization.assignments[0]
          saved_assignment.assignees = []
          if $scope.milestone.assignments == undefined
            $scope.milestone.assignments = []
          $scope.milestone.assignments.push(saved_assignment)
          $scope.new_assignment = AssignmentService.newAssignment('Milestone', $scope.milestone_id)


    $scope.viewTask  = (assignment) ->
      # Students go to user_assignment view
      if $scope.current_user.is_student
        user_assignment = _.findWhere(assignment.user_assignments, {user_id: $scope.current_user.id})
        $location.path("/user_assignment/#{user_assignment.id}")
        $location.url($location.path()) #Do this to remove query string params
      else
        $location.path("/assignment/#{assignment.id}")
        $location.url($location.path()) #Do this to remove query string params

]
