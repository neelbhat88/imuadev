angular.module('myApp')
.controller 'EditMilestoneModalController', ['$scope', '$modalInstance', 'RoadmapService',
                                              'selectedMilestone', 'timeUnit',
  ($scope, $modalInstance, RoadmapService, selectedMilestone, timeUnit) ->
    $scope.errors = []
    $scope.milestone = angular.copy(selectedMilestone)
    $scope.showAdvanced = false
    $scope.advancedPrefix = "Show"

    $scope.toggleAdvanced = () ->
      $scope.showAdvanced = !$scope.showAdvanced
      if $scope.showAdvanced
        $scope.advancedPrefix = "Hide"
      else
        $scope.advancedPrefix = "Show"

    $scope.save = () ->
      $scope.errors = []

      $scope.errors = RoadmapService.validateMilestone(timeUnit, $scope.milestone)

      if $scope.errors.length == 0
        RoadmapService.updateMilestone($scope.milestone)
        .success (data) ->
            angular.copy(data.milestone, selectedMilestone)
            $modalInstance.close()

    $scope.cancel = () ->
      $modalInstance.dismiss('cancel')

    $scope.delete = () ->
      if window.confirm "Are you sure you want to delete this milestone?"
        RoadmapService.deleteMilestone($scope.milestone.id)
        .success (data) ->
          $.each(timeUnit.milestones, (index, val) ->
            if this.id == $scope.milestone.id
              timeUnit.milestones.splice(index, 1)
              return false
          )

          $modalInstance.close();
]
