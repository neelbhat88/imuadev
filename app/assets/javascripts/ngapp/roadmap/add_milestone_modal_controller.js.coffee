angular.module('myApp')
.controller 'AddMilestoneModalController', ['$scope', '$modalInstance', 'timeUnit',
                                            'enabledModules', 'RoadmapService',
  ($scope, $modalInstance, timeUnit, enabledModules, RoadmapService) ->
    $scope.selected = {}
    $scope.errors = []
    $scope.showAdvanced = false
    $scope.advancedPrefix = "Show"

    # Build up the dd-modules array for a dropdown
    $scope.dd_modules = []

    for module in enabledModules
      moduleTitle = module.title

      for submodule in module.submodules
        new_milestone = angular.copy submodule.default_milestone
        new_milestone.id = null
        new_milestone.is_default = false
        new_milestone.time_unit_id = timeUnit.id

        $scope.dd_modules.push
          module: moduleTitle,
          submoduleTitle: submodule.title,
          submoduleType: submodule.submodtype,
          templatePath: '/assets/add_' + submodule.submodtype.toLowerCase() + '.html',
          milestone: new_milestone

    # Uncomment to have first module pre-selected
    # $scope.selected.module = $scope.dd_modules[0];

    $scope.selectModule = (module) ->
      $scope.selected.module = module

    $scope.toggleAdvanced = () ->
      $scope.showAdvanced = !$scope.showAdvanced
      if $scope.showAdvanced
        $scope.advancedPrefix = "Hide"
      else
        $scope.advancedPrefix = "Show"

    $scope.add = () ->
      $scope.errors = []
      new_milestone = $scope.selected.module.milestone

      $scope.errors = RoadmapService.validateMilestone(timeUnit, new_milestone)

      if $scope.errors.length == 0
        $modalInstance.close($scope.selected.module.milestone)

    $scope.cancel = () ->
      $modalInstance.dismiss('cancel')

]
