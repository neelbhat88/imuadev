angular.module('myApp')
.controller('AddMilestoneModalController', ['$scope', '$modalInstance', 'timeUnit',
                                            'enabledModules', 'RoadmapService',
  function($scope, $modalInstance, timeUnit, enabledModules, RoadmapService) {
    $scope.selected = {};
    $scope.errors = [];

    // Build up the dd-modules array for a dropdown
    $scope.dd_modules = [];
    $.each(enabledModules, function(index, val) {
      var moduleTitle = this.title;

      $.each(this.submodules, function(index, val) {
        var new_milestone = angular.copy(this.default_milestone);
        new_milestone.id = null;
        new_milestone.is_default = false;
        new_milestone.time_unit_id = timeUnit.id;

        $scope.dd_modules.push( { module: moduleTitle,
                                  submoduleTitle: this.title,
                                  submoduleType: this.type,
                                  templatePath: '/assets/add_' + this.type.toLowerCase() + '.html',
                                  milestone: new_milestone } );
      });
    });

    $scope.add = function()
    {
      $scope.errors = [];
      new_milestone = $scope.selected.module.milestone;

      $scope.errors = RoadmapService.validateMilestone(timeUnit, new_milestone);

      if ($scope.errors.length == 0)
        $modalInstance.close($scope.selected.module.milestone);
    };

    $scope.cancel = function() {
      $modalInstance.dismiss('cancel');
    };

  }
]);