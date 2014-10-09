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
