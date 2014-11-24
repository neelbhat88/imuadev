angular.module('myApp')
.controller 'AddMilestoneModalController', ['$scope', '$modalInstance', 'timeUnit',
                                            'enabledModules', 'RoadmapService',
  ($scope, $modalInstance, timeUnit, enabledModules, RoadmapService) ->
    $scope.selected = {}
    $scope.errors = []
    $scope.showAdvanced = false
    $scope.advancedPrefix = "Show"

    $scope.modules = enabledModules
    $scope.selected.module = $scope.modules[0]

    $scope.selectModule = (module) ->
      $scope.selected.module = module
      $scope.selected.submodule = null

    $scope.selectSubmodule = (submodule) ->
      $scope.selected.submodule = submodule

    $scope.clearSubmoduleSelection = () ->
      $scope.selected.submodule = null

    $scope.toggleAdvanced = () ->
      $scope.showAdvanced = !$scope.showAdvanced
      if $scope.showAdvanced
        $scope.advancedPrefix = "Hide"
      else
        $scope.advancedPrefix = "Show"

    $scope.add = () ->
      $scope.errors = []
      new_milestone = $scope.selected.submodule
      new_milestone.is_default = false
      new_milestone.time_unit_id = timeUnit.id

      $scope.errors = RoadmapService.validateMilestone(timeUnit, new_milestone)

      if $scope.errors.length == 0
        $modalInstance.close($scope.selected.submodule)

    $scope.cancel = () ->
      $modalInstance.dismiss('cancel')

]
