angular.module('myApp')
.controller 'MilestoneController', ['$scope', '$route', 'current_user', 'milestone_id', 'edit', 'MilestoneService', 'UsersService', 'OrganizationService', 'RoadmapService',
  ($scope, $route, current_user, milestone_id, edit, MilestoneService, UsersService, OrganizationService, RoadmapService) ->

    $scope.showAdvanced = false
    $scope.advancedPrefix = "Show"

    MilestoneService.getMilestoneStatus(milestone_id)
      .success (data) ->
        $scope.organization = OrganizationService.parseOrganizationWithUsers(data.organization)
        $scope.users_total = $scope.organization.students
        $scope.milestone = $scope.organization.milestones[0]
        partition = _.partition($scope.users_total, (u) -> u.user_milestones and u.user_milestones.length > 0)
        $scope.users_complete = partition[0]
        $scope.users_incomplete = partition[1]
        $scope.percent_complete = (($scope.users_complete.length / $scope.users_total.length) * 100).toFixed(0)
        $scope.loaded_data = true

    $scope.toggleAdvanced = () ->
      $scope.showAdvanced = !$scope.showAdvanced
      $scope.advancedPrefix = if $scope.showAdvanced then "Hide" else "Show"

    $scope.save = () ->
      RoadmapService.updateMilestone($scope.milestone)
        .success (data) ->
          saved_milestone = data.milestone_status
          $scope.milestone = saved_milestone
          $scope.milestone.editing = false

    $scope.cancel = () ->
      if !$scope.milestone.id
        window.location.href = "#/roadmap/" + $scope.milestone.organization_id
      else
        window.location.href = "#/roadmap/" + $scope.milestone.organization_id
        #$scope.milestone.editing = false

    $scope.delete = () ->
      if window.confirm "Are you sure you want to delete this milestone?"
        RoadmapService.deleteMilestone($scope.milestone.id)
          .success (data) ->
            window.location.href = "#/roadmap/" + $scope.milestone.organization_id

]
