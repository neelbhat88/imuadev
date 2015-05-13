angular.module('myApp')
.controller 'MilestoneController', ['$scope', '$route', 'current_user', 'milestone_id', 'edit', 'MilestoneService', 'UsersService', 'OrganizationService', 'RoadmapService', 'ProgressService',
  ($scope, $route, current_user, milestone_id, edit, MilestoneService, UsersService, OrganizationService, RoadmapService, ProgressService) ->

    $scope.current_user = current_user
    $scope.selectionMode = false
    $scope.groupSelected = {}

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

    MilestoneService.getMilestoneStatus(milestone_id)
      .success (data) ->
        $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
        $scope.users_total = $scope.organization.students
        for student in $scope.users_total
          student.is_selected = false
        $scope.milestone = $scope.organization.milestones[0]
        $scope.milestone.editing = false
        $scope.recalculateCompletion()
        $scope.loaded_data = true

    $scope.userMilestonesAreEditable = (milestone) ->
      return milestone.submodule == "YesNo"

    $scope.setUserMilestone = (user) ->
      ProgressService.addUserMilestone(user, $scope.milestone.time_unit_id, $scope.milestone.id)
        .success (data) ->
          if !user.user_milestones
            user.user_milestones = []
          user.user_milestones.push({})
          $scope.recalculateCompletion()

    $scope.unsetUserMilestone = (user) ->
      ProgressService.deleteUserMilestone(user, $scope.milestone.time_unit_id, $scope.milestone.id)
        .success (data) ->
          user.user_milestones = []
          $scope.recalculateCompletion()

    $scope.setSelectedClass = (is_selected) ->
      if is_selected
        'is-selected-photo'
      else
        ''

    $scope.studentSelect = (student) ->
      student.is_selected = !student.is_selected
      $scope.$broadcast("studentSelect", student)

    $scope.toggleSelectionMode = () ->
      $scope.selectionMode = !$scope.selectionMode
      $scope.$broadcast("toggleSelectionMode")

    $scope.selectGroup = (students, groupIsSelected) ->
      args = {}
      args.students = students
      for student in students
        student.is_selected = groupIsSelected
      args.groupIsSelected = groupIsSelected
      $scope.$broadcast("selectGroup", args)

    $scope.$on("clearSelected", (event) ->
      $scope.groupSelected.incomplete = false
      $scope.groupSelected.complete = false
    )


]
