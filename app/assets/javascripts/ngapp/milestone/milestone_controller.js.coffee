angular.module('myApp')
.controller 'MilestoneController', ['$scope', '$route', 'current_user', 'milestone_id', 'edit', 'MilestoneService', 'UsersService', 'OrganizationService', 'RoadmapService', 'ProgressService',
  ($scope, $route, current_user, milestone_id, edit, MilestoneService, UsersService, OrganizationService, RoadmapService, ProgressService) ->

    $scope.showAdvanced = false
    $scope.advancedPrefix = "Show"

    $scope.recalculateCompletion = () =>
        partition = _.partition($scope.users_total, (u) -> u.user_milestones and u.user_milestones.length > 0)
        $scope.users_complete = partition[0]
        $scope.users_incomplete = partition[1]
        $scope.percent_complete = (($scope.users_complete.length / $scope.users_total.length) * 100).toFixed(0)

    MilestoneService.getMilestoneStatus(milestone_id)
      .success (data) ->
        $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
        $scope.users_total = $scope.organization.students
        $scope.milestone = $scope.organization.milestones[0]
        $scope.milestone.editing = false
        $scope.recalculateCompletion()
        $scope.loaded_data = true

    $scope.editMilestone = () ->
      $scope.milestone.editing = true
      $scope.milestone.new_value = $scope.milestone.value
      $scope.milestone.new_points = $scope.milestone.points

    $scope.cancelEditMilestone = () ->
      # Go back to roadmap page if cancelled creating a new milestone
      if !$scope.milestone.id
        window.location.href = "#/roadmap/" + $scope.milestone.organization_id
      else
        $scope.milestone.editing = false

    $scope.toggleAdvanced = () ->
      $scope.showAdvanced = !$scope.showAdvanced
      $scope.advancedPrefix = if $scope.showAdvanced then "Hide" else "Show"

    $scope.saveMilestone = () ->
      m = $scope.milestone
      new_milestone = MilestoneService.newMilestone(m.organization_id, m.time_unit_id, m.module, m.submodule, m.title, m.description, m.icon)
      new_milestone.id = m.id
      new_milestone.value = m.new_value
      new_milestone.points = m.new_points
      RoadmapService.updateMilestone(new_milestone)
        .success (data) ->
          $scope.milestone = data.milestone_status
          $scope.milestone.editing = false

    $scope.deleteMilestone = () ->
      if window.confirm "Are you sure you want to delete this milestone?"
        RoadmapService.deleteMilestone($scope.milestone.id)
          .success (data) ->
            window.location.href = "#/roadmap/" + $scope.milestone.organization_id

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
]
