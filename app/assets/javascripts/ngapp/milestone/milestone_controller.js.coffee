angular.module('myApp')
.controller 'MilestoneController', ['$scope', '$route', '$location', 'current_user', 'milestone_id', 'edit', 'MilestoneService', 'UsersService', 'OrganizationService', 'RoadmapService', 'ProgressService', 'AssignmentService',
  ($scope, $route, $location, current_user, milestone_id, edit, MilestoneService, UsersService, OrganizationService, RoadmapService, ProgressService, AssignmentService) ->

    $scope.milestone_id = milestone_id
    $scope.current_user = current_user
    $scope.new_assignment = AssignmentService.newAssignment('Milestone', milestone_id)

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

    $scope.saveAssignment = (assignment) ->
      # Always assign all assignable users
      AssignmentService.broadcastAssignment(assignment, _.map($scope.users_total, (assignee) -> assignee.id))
        .success (data) ->
          organization = OrganizationService.parseOrganizationWithUsers(data.organization)
          saved_assignment =  organization.assignments[0]
          saved_assignment.assignees = []
          _.push($scope.milestone.assignments, saved_assignment)

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
